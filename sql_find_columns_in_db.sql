SELECT t.table_name,
       COUNT(*) AS total_fields
FROM information_schema.tables t
JOIN information_schema.columns c 
  ON c.table_name = t.table_name 
  AND c.table_schema = t.table_schema
JOIN (
    SELECT table_name,
           table_schema
    FROM information_schema.tables
    WHERE table_type = 'BASE TABLE'
      AND table_schema NOT IN ('information_schema', 'pg_catalog')
) sub
  ON t.table_name = sub.table_name
  AND t.table_schema = sub.table_schema
WHERE c.column_name LIKE 'file%'
GROUP BY t.table_name
HAVING COUNT(*) > 0
ORDER BY t.table_name;
