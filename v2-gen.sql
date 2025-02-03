/**
  @fewalthel
 */

-- Определение функции для генерации имени и фамилии сотрудника
CREATE FUNCTION random_employee_name() RETURNS TEXT AS
$$
DECLARE
    first_names TEXT[] := ARRAY [
        'James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Joseph', 'Charles', 'Thomas',
        'Mary', 'Jennifer', 'Linda', 'Patricia', 'Elizabeth', 'Susan', 'Jessica', 'Sarah', 'Karen', 'Nancy'
        ];
    last_names  TEXT[] := ARRAY [
        'Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor',
        'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Thompson', 'Garcia', 'Martinez', 'Roberts'
        ];
BEGIN
    RETURN first_names[random_int(1, array_length(first_names, 1))] || ' ' ||
           last_names[random_int(1, array_length(last_names, 1))];
END
$$;

-- Вставка случайных данных в таблицу employees
DO
$$
    DECLARE
        i INT := 0;
    BEGIN
        WHILE i < 200
            LOOP
                INSERT INTO employees (first_name, last_name, email, hire_date, salary)
                VALUES (split_part(random_employee_name(), ' ', 1),
                        split_part(random_employee_name(), ' ', 2),
                        random_string('email', i) || '@mail.com',
                        random_date(365 * 5),
                        (random_int(5000, 15000))::TEXT);
                i := i + 1;
            END LOOP;
    END
$$;

-- Вставка случайных данных в таблицу projects
DO
$$
    DECLARE
        i            INT := 0;
        project_name TEXT;
        start_date   DATE;
        end_date     DATE;
        budget       TEXT;
    BEGIN
        WHILE i < 100
            LOOP
                -- Генерация случайного имени проекта
                project_name := 'Project_№' || (i + 1);

                -- Генерация случайных дат
                start_date := CURRENT_DATE - (random() * 365)::INT;
                end_date := CURRENT_DATE + (random() * 365)::INT;

                -- Генерация случайного бюджета
                budget := (floor(random() * (15000000 - 1000000 + 1) + 1000000))::TEXT;

                -- Вставка данных в таблицу
                INSERT INTO projects (project_name, start_date, end_date, budget)
                VALUES (project_name, start_date, end_date, budget);

                i := i + 1;
            END LOOP;
    END
$$;

-- Генерация случайных задач для проектов
DO
$$
    DECLARE
        project     RECORD;
        task_name   TEXT;
        description TEXT;
        start_date  DATE;
        end_date    DATE;
        status      TEXT;
    BEGIN
        -- Перебор всех проектов в таблице projects
        FOR project IN SELECT project_id FROM projects
            LOOP
                -- Генерация случайных задач для каждого проекта
                FOR i IN 1..(random() * 5 + 1)::INT
                    LOOP
                        -- Максимум 5 задач на проект
                        task_name := 'Task_№' || (i + 1); -- Случайное имя задачи
                        description := 'Description of ' || task_name; -- Описание задачи
                        start_date := CURRENT_DATE - (random() * 365)::INT; -- Случайная дата начала
                        end_date := start_date + (random() * 30)::INT; -- Случайная дата окончания (в пределах 30 дней)
                        status := CASE WHEN random() > 0.5 THEN 'In Progress' ELSE 'Completed' END;
                        -- Случайный статус задачи

                        -- Вставка данных в таблицу tasks
                        INSERT INTO tasks (project_id, task_name, description, start_date, end_date, status)
                        VALUES (project.project_id, task_name, description, start_date, end_date, status);
                    END LOOP;
            END LOOP;
    END
$$;