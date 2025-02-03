/**
  @fewalthel
 */

BEGIN;

-- Изменение типа столбца salary
ALTER TABLE employees
    ALTER COLUMN salary TYPE DECIMAL(10, 2);

-- Добавление столбца phone_number в таблицу employees
ALTER TABLE employees
    ADD COLUMN phone_number VARCHAR(15);

-- Добавление столбца description в таблицу projects
ALTER TABLE projects
    ADD COLUMN description TEXT;

-- Добавление ограничения NOT NULL на столбец email
ALTER TABLE employees
    ALTER COLUMN email SET NOT NULL;

-- Добавление уникального ограничения на столбец task_name
ALTER TABLE tasks
    ADD CONSTRAINT unique_task_name UNIQUE (task_name);

-- Если все прошло успешно, применяем изменения
COMMIT;

-- Если что-то пошло не так, откатываем все изменения
ROLLBACK;