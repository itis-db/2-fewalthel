/**
  @fewalthel
 */

BEGIN;

-- 1. Удаляем старые внешние ключи, чтобы можно было менять ключи в родительских таблицах
ALTER TABLE employee_roles DROP CONSTRAINT employee_roles_employee_id_fkey;
ALTER TABLE employee_roles DROP CONSTRAINT employee_roles_project_id_fkey;
ALTER TABLE employee_roles DROP CONSTRAINT employee_roles_role_id_fkey;
ALTER TABLE work_history DROP CONSTRAINT work_history_employee_id_fkey;
ALTER TABLE work_history DROP CONSTRAINT work_history_task_id_fkey;
ALTER TABLE tasks DROP CONSTRAINT tasks_project_id_fkey;

-- 2. Создаем новые версии таблиц с доменными ключами

-- Таблица сотрудников (ключ - email)
CREATE TABLE employees_new (
    email       VARCHAR(100) PRIMARY KEY,
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    hire_date   DATE,
    salary      VARCHAR(10)
);

INSERT INTO employees_new (email, first_name, last_name, hire_date, salary)
SELECT email, first_name, last_name, hire_date, salary FROM employees;

DROP TABLE employees;
ALTER TABLE employees_new RENAME TO employees;

-- Таблица проектов (ключ - project_name + start_date)
CREATE TABLE projects_new (
    project_name VARCHAR(300),
    start_date   DATE,
    end_date     DATE,
    budget       VARCHAR(30),
    PRIMARY KEY (project_name, start_date)
);

INSERT INTO projects_new (project_name, start_date, end_date, budget)
SELECT project_name, start_date, end_date, budget FROM projects;

DROP TABLE projects;
ALTER TABLE projects_new RENAME TO projects;

-- Таблица задач (ключ - task_name + project_name + start_date)
CREATE TABLE tasks_new (
    task_name     VARCHAR(255),
    project_name  VARCHAR(300),
    project_start DATE,
    description   TEXT,
    start_date    DATE,
    end_date      DATE,
    status        VARCHAR(50) DEFAULT 'Not Started',
    PRIMARY KEY (task_name, project_name, project_start),
    FOREIGN KEY (project_name, project_start) REFERENCES projects (project_name, start_date)
);

INSERT INTO tasks_new (task_name, project_name, project_start, description, start_date, end_date, status)
SELECT task_name,
       (SELECT project_name FROM projects WHERE projects.project_id = tasks.project_id) AS project_name,
       (SELECT start_date FROM projects WHERE projects.project_id = tasks.project_id) AS project_start,
       description, start_date, end_date, status
FROM tasks;

DROP TABLE tasks;
ALTER TABLE tasks_new RENAME TO tasks;

-- Таблица ролей (ключ - role_name)
CREATE TABLE roles_new (
    role_name VARCHAR(100) PRIMARY KEY
);

INSERT INTO roles_new (role_name)
SELECT role_name FROM roles;

DROP TABLE roles;
ALTER TABLE roles_new RENAME TO roles;

-- Таблица связи сотрудников и ролей в проектах (ключи - email, project_name, start_date, role_name)
CREATE TABLE employee_roles_new (
    email         VARCHAR(100),
    project_name  VARCHAR(300),
    project_start DATE,
    role_name     VARCHAR(100),
    PRIMARY KEY (email, project_name, project_start, role_name),
    FOREIGN KEY (email) REFERENCES employees (email),
    FOREIGN KEY (project_name, project_start) REFERENCES projects (project_name, start_date),
    FOREIGN KEY (role_name) REFERENCES roles (role_name)
);

INSERT INTO employee_roles_new (email, project_name, project_start, role_name)
SELECT
    (SELECT email FROM employees WHERE employees.employee_id = employee_roles.employee_id) AS email,
    (SELECT project_name FROM projects WHERE projects.project_id = employee_roles.project_id) AS project_name,
    (SELECT start_date FROM projects WHERE projects.project_id = employee_roles.project_id) AS project_start,
    (SELECT role_name FROM roles WHERE roles.role_id = employee_roles.role_id) AS role_name
FROM employee_roles;

DROP TABLE employee_roles;
ALTER TABLE employee_roles_new RENAME TO employee_roles;

-- Таблица истории работы сотрудников (ключи - email, task_name, project_name, start_date, work_date)
CREATE TABLE work_history_new (
    email         VARCHAR(100),
    task_name     VARCHAR(255),
    project_name  VARCHAR(300),
    project_start DATE,
    work_date     DATE,
    hours_worked  VARCHAR(20),
    PRIMARY KEY (email, task_name, project_name, project_start, work_date),
    FOREIGN KEY (email) REFERENCES employees (email),
    FOREIGN KEY (task_name, project_name, project_start) REFERENCES tasks (task_name, project_name, project_start)
);

INSERT INTO work_history_new (email, task_name, project_name, project_start, work_date, hours_worked)
SELECT
    (SELECT email FROM employees WHERE employees.employee_id = work_history.employee_id) AS email,
    (SELECT task_name FROM tasks WHERE tasks.task_id = work_history.task_id) AS task_name,
    (SELECT project_name FROM tasks JOIN projects ON tasks.project_id = projects.project_id
     WHERE tasks.task_id = work_history.task_id) AS project_name,
    (SELECT start_date FROM tasks JOIN projects ON tasks.project_id = projects.project_id
     WHERE tasks.task_id = work_history.task_id) AS project_start,
    work_date, hours_worked
FROM work_history;

DROP TABLE work_history;
ALTER TABLE work_history_new RENAME TO work_history;

-- Если все прошло успешно, применяем изменения
COMMIT;

-- Если что-то пошло не так, откатываем все изменения
ROLLBACK;