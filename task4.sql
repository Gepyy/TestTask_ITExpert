SET SQL_SAFE_UPDATES = 0;

UPDATE skill_variants sv
-- З’єднуємо таблицю skill_variants з підзапитом по id навички.
JOIN (
-- Підзапит що підраховує кількість унікальних кандидатів для кожної навички
    SELECT 
        variant_id,
        COUNT(DISTINCT candidate_id) AS candidate_count
    FROM candidate_skills
    GROUP BY variant_id
) cs ON sv.id = cs.variant_id
SET sv.cnt = IFNULL(cs.candidate_count, 0);

-- або
-- Майже та сама логіка але тут можна без SET SQL_SAFE_UPDATES = 0;
UPDATE skill_variants sv
JOIN (
    SELECT 
        variant_id,
        COUNT(DISTINCT candidate_id) AS candidate_count
    FROM candidate_skills
    GROUP BY variant_id
) cs ON sv.id = cs.variant_id
SET sv.cnt = IFNULL(cs.candidate_count, 0)
WHERE sv.id = sv.id; 

-- Перевірка результату (цілком для себе)
SELECT id, name, cnt
FROM skill_variants
ORDER BY cnt DESC;


