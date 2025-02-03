/**
 @fewalthel
*/

-- Таблица сотрудников
CREATE TABLE employees
(
    employee_id SERIAL PRIMARY KEY,
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(100) UNIQUE,
    hire_date   DATE,
    salary      VARCHAR(10)
);

-- Таблица проектов
CREATE TABLE projects
(
    project_id   SERIAL PRIMARY KEY,
    project_name VARCHAR(300) NOT NULL,
    start_date   DATE,
    end_date     DATE,
    budget       VARCHAR(30)
);

-- Таблица задач
CREATE TABLE tasks
(
    task_id     SERIAL PRIMARY KEY,
    project_id  INT,
    task_name   VARCHAR(255) NOT NULL,
    description TEXT,
    start_date  DATE,
    end_date    DATE,
    status      VARCHAR(50) DEFAULT 'Not Started',
    FOREIGN KEY (project_id) REFERENCES projects (project_id)
);

-- Таблица ролей сотрудников в проекте
CREATE TABLE roles
(
    role_id   SERIAL PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL
);

-- Таблица связи сотрудников и ролей в проектах
CREATE TABLE employee_roles
(
    employee_id INT,
    project_id  INT,
    role_id     INT,
    PRIMARY KEY (employee_id, project_id, role_id),
    FOREIGN KEY (employee_id) REFERENCES employees (employee_id),
    FOREIGN KEY (project_id) REFERENCES projects (project_id),
    FOREIGN KEY (role_id) REFERENCES roles (role_id)
);

-- Таблица истории работы сотрудников
CREATE TABLE work_history
(
    work_id      SERIAL PRIMARY KEY,
    employee_id  INT,
    task_id      INT,
    hours_worked VARCHAR(20),
    work_date    DATE,
    FOREIGN KEY (employee_id) REFERENCES employees (employee_id),
    FOREIGN KEY (task_id) REFERENCES tasks (task_id)
);