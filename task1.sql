 -- rename all values
SELECT
    es.user_uid AS candidate_id,
    c.full_name,
    c.linkedin_url,
    es.vacancy_id,
    v.title AS vacancy_title,
    es.creation_date,
    es.comment_text,
    c.is_friend,
    c.is_pro
 -- select candidate statuses from the early_statuses table
FROM early_statuses es
JOIN candidates c ON c.id = es.user_uid
JOIN vacancies v ON v.id = es.vacancy_id
-- HR access rights check
JOIN access ac_c ON ac_c.entity_type = 'candidate' AND ac_c.entity_id = c.id 
                  AND ac_c.hr_id = 1 AND ac_c.right_code = 'Read'
JOIN access ac_v ON ac_v.entity_type = 'vacancy' AND ac_v.entity_id = v.id 
                  AND ac_v.hr_id = 1 AND ac_v.right_code = 'Read'
-- select only leads
WHERE es.type_id = 1
  AND es.creation_date BETWEEN '2025-03-01' AND '2025-03-31'
-- verification that there are no later statuses for the same candidate and vacancy.
  AND NOT EXISTS (
      SELECT 1
      FROM early_statuses es2
      WHERE es2.user_uid = es.user_uid
        AND es2.vacancy_id = es.vacancy_id
        AND es2.creation_date > es.creation_date
  )
-- перевірка, що немає відправлених резюме
  AND NOT EXISTS (
      SELECT 1
      FROM resumes r
      WHERE r.candidate_id = es.user_uid
        AND r.vacancy_id = es.vacancy_id
        AND r.sent_at IS NOT NULL
  )
-- сортування результату по даті від раннього до старішого (якщо що, комент строка для сортування навпаки).
ORDER BY es.creation_date ASC
-- ORDER BY es.creation_date DESC;

