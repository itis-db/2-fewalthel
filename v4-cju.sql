/**
  @fewalthel
 */

/*Запрос с использованием CTE: Список проектов и количество сотрудников в каждом проекте.*/
/*В employee_counts считается количество уникальных сотрудников в каждом проекте.
Затем это значение соединяется с таблицей projects.*/
WITH employee_counts AS (SELECT project_id,
                                COUNT(DISTINCT employee_id) AS employee_count
                         FROM employee_roles
                         GROUP BY project_id)
SELECT p.project_id,
       p.project_name,
       ec.employee_count
FROM projects p
         LEFT JOIN employee_counts ec ON p.project_id = ec.project_id;

/*Запрос с использованием JOIN: Список сотрудников и их задач по проектам.*/
/*Выводит список сотрудников, проектов и задач, над которыми они работают, включая статус задачи.
Использует несколько JOIN для объединения данных.*/
SELECT e.first_name,
       e.last_name,
       p.project_name,
       t.task_name,
       t.status
FROM employees e
         JOIN employee_roles er ON e.employee_id = er.employee_id
         JOIN projects p ON er.project_id = p.project_id
         JOIN tasks t ON p.project_id = t.project_id
ORDER BY e.last_name,
         p.project_name,
         t.task_name;

/*Запрос с использованием UNION: Сотрудники и роли (объединение двух списков).*/
/*Объединяет список всех сотрудников с их именами и список всех ролей в одном запросе.
Добавляет колонку role_type, чтобы различать сотрудников и роли.*/
SELECT e.employee_id,
       e.first_name ' ' e.last_name AS full_name, 'Employee' AS role_type
FROM employees e
UNION
SELECT r.role_id,
       r.role_name AS full_name,
       'Role'      AS role_type
FROM roles r;

/*Запрос с использованием CTE: Суммарное время работы сотрудников по проектам.*/
/*Считает суммарное время, затраченное сотрудниками на задачи по проектам.
Использует CTE для предварительного вычисления времени, а затем выводит результаты с именами сотрудников и проектов.*/
WITH work_hours AS (SELECT t.project_id,
                           w.employee_id,
                           SUM(CAST(w.hours_worked AS FLOAT)) AS total_hours
                    FROM work_history w
                             JOIN tasks t ON w.task_id = t.task_id
                    GROUP BY t.project_id,
                             w.employee_id)
SELECT p.project_name,
       e.first_name ' ' e.last_name AS employee_name, wh.total_hours
FROM work_hours wh
         JOIN projects p ON wh.project_id = p.project_id
         JOIN employees e ON wh.employee_id = e.employee_id
ORDER BY p.project_name,
         wh.total_hours DESC;

/*Запрос с использованием CTE и JOIN: Проекты, где нет активных задач.*/
/*Определяет проекты, где нет задач в статусах "Completed" или "Canceled".
Использует CTE для подсчета активных задач.*/
WITH active_tasks AS (SELECT project_id,
                             COUNT(*) AS active_task_count
                      FROM tasks
                      WHERE status NOT IN ('Completed', 'Canceled')
                      GROUP BY project_id)
SELECT p.project_id,
       p.project_name,
       p.budget
FROM projects p
         LEFT JOIN active_tasks at ON p.project_id = at.project_id
WHERE at.active_task_count IS NULL;

/*Запрос с UNION: Сотрудники с задачами и сотрудники без задач.*/
/*Объединяет сотрудников, у которых есть задачи, и тех, у кого задач нет.
Эти запросы используют основные возможности SQL (CTE, JOIN, UNION) для выполнения полезных аналитических задач на основе вашей схемы.*/
SELECT e.employee_id,
       e.first_name ' ' e.last_name AS full_name, 'With Tasks' AS task_status
FROM employees e
         JOIN work_history w ON e.employee_id = w.employee_id
UNION
SELECT e.employee_id,
       e.first_name ' ' e.last_name AS full_name, 'Without Tasks' AS task_status
FROM employees e
WHERE NOT EXISTS (SELECT 1
                  FROM work_history w
                  WHERE e.employee_id = w.employee_id);