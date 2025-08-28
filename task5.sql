SELECT
    r.id AS reminder_id,
    r.remdate,
    r.candidate_id,
    c.full_name,
    r.note
FROM reminders r
JOIN candidates c ON c.id = r.candidate_id
-- Перевіряю права доступу HR на нагадування
JOIN access ac ON ac.entity_type = 'reminder'
              AND ac.entity_id = r.id
              AND ac.hr_id = 1
              AND ac.right_code = 'Read'
-- Дата сьогодні
-- WHERE r.remdate >= UTC_DATE()
-- AND r.remdate <  UTC_DATE() + INTERVAL 1 DAY
WHERE r.remdate >= '2025-03-15 00:00:00'
AND r.remdate < '2025-03-15 00:00:00' + INTERVAL 1 DAY
ORDER BY r.remdate ASC;
