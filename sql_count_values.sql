SELECT 
    guessed_file_extension,
    COUNT(*) AS row_count
FROM 
    public.cloud_file
GROUP BY 
    guessed_file_extension
HAVING 
    COUNT(*) > 0
ORDER BY 
    row_count DESC
LIMIT 1000;
