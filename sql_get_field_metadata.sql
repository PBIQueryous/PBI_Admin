-- Using information_schema
SELECT 
    column_name,
    data_type
FROM 
    information_schema.columns
WHERE 
    table_schema = 'public' 
    AND table_name = 'job';

-- Using pg_catalog
SELECT 
    attname AS column_name,
    typname AS data_type
FROM 
    pg_catalog.pg_attribute a
JOIN 
    pg_catalog.pg_class c ON a.attrelid = c.oid
JOIN 
    pg_catalog.pg_type t ON a.atttypid = t.oid
JOIN 
    pg_catalog.pg_namespace n ON c.relnamespace = n.oid
WHERE 
    c.relname = 'order'
    AND n.nspname = 'public'
    AND a.attnum > 0
    AND NOT a.attisdropped;
