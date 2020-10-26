-- -----------------------------------------------------------------------------------
-- File Name    : df_usage_04.sql
-- Description  : Displays space usage for each datafile
-- Requirements : Access to the DBA views.
-- Call Syntax  : @df_usage_04.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET PAGESIZE 1000
SET LINESIZE 255
SET FEEDBACK OFF

SELECT Substr(df.tablespace_name,1,20) "Tablespace Name",
       Substr(df.file_name,1,60) "File Name",
       Round(df.bytes/1024/1024/1024,2) "Size (G)",
       Round(e.used_bytes/1024/1024/1024,2) "Used (G)",
       Round(f.free_bytes/1024/1024/1024,2) "Free (G)",
       Rpad(' '|| Rpad ('X',Round(e.used_bytes*10/df.bytes,0), 'X'),11,'-') "% Used"
FROM   DBA_DATA_FILES DF,
       (SELECT file_id,
               Sum(Decode(bytes,NULL,0,bytes)) used_bytes
        FROM dba_extents
        GROUP by file_id) E,
       (SELECT Max(bytes) free_bytes,
               file_id
        FROM dba_free_space
        GROUP BY file_id) f
WHERE  e.file_id (+) = df.file_id
AND    df.file_id  = f.file_id (+)
ORDER BY df.tablespace_name,
         df.file_name;

PROMPT
SET FEEDBACK ON
SET PAGESIZE 18
