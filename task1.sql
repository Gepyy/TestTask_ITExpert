WITH later_statuses AS (
    -- усі статуси для кандидатів з тієї ж пари кандидат–вакансія, які пізніші за лід
    SELECT user_uid, vacancy_id, MIN(creation_date) AS min_later_date
    FROM early_statuses
    WHERE creation_date >= '2025-03-01 00:00:00'
      AND creation_date <  '2025-04-01 00:00:00'
    GROUP BY user_uid, vacancy_id
)
SELECT
    es.user_uid AS candidate_id,
    c.full_name,
    c.linkedin_url,
    es.vacancy_id,
    v.title AS vacancy_title,
    es.creation_date,
    COALESCE(es.comment_text,'') AS comment_text,
    c.is_friend,
    c.is_pro
FROM early_statuses es
JOIN candidates c ON c.id = es.user_uid
JOIN vacancies v ON v.id = es.vacancy_id
-- перевіряю доступ HR
JOIN access ac_c ON ac_c.entity_type = 'candidate' 
                 AND ac_c.entity_id = c.id 
                 AND ac_c.hr_id = 1 
                 AND ac_c.right_code = 'Read'
JOIN access ac_v ON ac_v.entity_type = 'vacancy' 
                 AND ac_v.entity_id = v.id 
                 AND ac_v.hr_id = 1 
                 AND ac_v.right_code = 'Read'
-- Беремо лише лідів
WHERE es.type_id = 1
  AND es.creation_date >= '2025-03-01 00:00:00'
  AND es.creation_date <  '2025-04-01 00:00:00'
  -- немає пізніших статусів для того ж кандидата і вакансії
  AND NOT EXISTS (
      SELECT 1
      FROM early_statuses es2
      WHERE es2.user_uid = es.user_uid
        AND es2.vacancy_id = es.vacancy_id
        AND es2.creation_date > es.creation_date
  )
  -- немає відправлених резюме
  AND NOT EXISTS (
      SELECT 1
      FROM resumes r
      WHERE r.candidate_id = es.user_uid
        AND r.vacancy_id = es.vacancy_id
        AND r.sent_at IS NOT NULL
  )
ORDER BY es.creation_date ASC;
