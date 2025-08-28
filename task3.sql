-- Створюємо тимчасову таблицю
CREATE TEMPORARY TABLE kpi_table (
    day_date DATE,
    hr_id INT,
    leads_created INT,
    statuses_added INT,
    resumes_prepared INT,
    resumes_sent INT,
    calls_made INT,
    contracts_signed INT
);

-- Вставляю дані за вчорашній день
INSERT INTO kpi_table (day_date, hr_id, leads_created, statuses_added, resumes_prepared, resumes_sent, calls_made, contracts_signed)
WITH
-- Підраховую статуси для кожного HR
status_counts AS (
    SELECT 
        created_by AS hr_id,
        SUM(CASE WHEN type_id = 1 THEN 1 ELSE 0 END) AS leads_created,
        SUM(CASE WHEN type_id <> 1 THEN 1 ELSE 0 END) AS statuses_added,
        SUM(CASE WHEN type_id = 3 THEN 1 ELSE 0 END) AS resumes_prepared,
        SUM(CASE WHEN type_id = 2 THEN 1 ELSE 0 END) AS calls_made,
        SUM(CASE WHEN type_id = 10 THEN 1 ELSE 0 END) AS contracts_signed
    FROM early_statuses
    WHERE creation_date >= UTC_DATE() - INTERVAL 1 DAY
      AND creation_date <  UTC_DATE()
    GROUP BY created_by
),
-- Підраховую відправлені резюме
resumes_counts AS (
    SELECT
        created_by AS hr_id,
        COUNT(*) AS resumes_sent
    FROM resumes
    WHERE sent_at >= UTC_DATE() - INTERVAL 1 DAY
      AND sent_at <  UTC_DATE()
      AND sent_at IS NOT NULL
    GROUP BY created_by
)
SELECT
    UTC_DATE() - INTERVAL 1 DAY AS day_date,
    u.id AS hr_id,
    IFNULL(sc.leads_created, 0) AS leads_created,
    IFNULL(sc.statuses_added, 0) AS statuses_added,
    IFNULL(sc.resumes_prepared, 0) AS resumes_prepared,
    IFNULL(rc.resumes_sent, 0) AS resumes_sent,
    IFNULL(sc.calls_made, 0) AS calls_made,
    IFNULL(sc.contracts_signed, 0) AS contracts_signed
FROM aspnetusers u
LEFT JOIN statresumesus_counts sc ON sc.hr_id = u.id
LEFT JOIN resumes_counts rc ON rc.hr_id = u.id;

-- Перевірка результатів
SELECT *
FROM kpi_table
ORDER BY hr_id;



