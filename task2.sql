SELECT
    vacancies.id AS vacancy_id,
    vacancies.title AS vacancy_title,
    DATE_FORMAT('2025-03-01', '%Y-%m') AS month,
-- рахую значення як вказано в завданні
    COUNT(DISTINCT IFNULL(early_statuses.user_uid, 0)) AS total_candidates,
    COUNT(DISTINCT IFNULL(resumes.id, 0)) AS resumes_sent,
    COUNT(CASE WHEN early_statuses.type_id = 10 THEN 1 END) AS contracts,
    COUNT(CASE WHEN early_statuses.type_id = 11 THEN 1 END) AS rejections,
    COUNT(CASE WHEN early_statuses.type_id = 2 THEN 1 END) AS calls,
    COUNT(CASE WHEN early_statuses.type_id IN (12,14) THEN 1 END) AS interviews
FROM vacancies
-- Приєдную всі події до кожної вакансії.
LEFT JOIN early_statuses
       ON early_statuses.vacancy_id = vacancies.id
      AND early_statuses.creation_date >= '2025-03-01 00:00:00'
      AND early_statuses.creation_date <  '2025-04-01 00:00:00'
-- Приєдную всі резюме, які були відправлені за березень, до кожної вакансії.
LEFT JOIN resumes
       ON resumes.vacancy_id = vacancies.id
      AND resumes.sent_at >= '2025-03-01 00:00:00'
      AND resumes.sent_at <  '2025-04-01 00:00:00'
-- агрегую статистику
GROUP BY vacancies.id, vacancies.title
-- Сортую результат за ID вакансії.
ORDER BY vacancies.id;
