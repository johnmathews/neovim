-- Test file for SQL highlighting and formatting (sqlfluff via conform).
-- Intentionally messy layout so the formatter has work to do.
select id,name ,email from users where active=true and created_at > '2026-01-01' order by name;

SELECT u.id, COUNT(o.id) AS order_count
FROM users u LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.id
HAVING COUNT(o.id) > 1;

insert into users (name, email) values ('Ada', 'ada@example.com');
