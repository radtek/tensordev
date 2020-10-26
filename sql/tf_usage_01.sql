-- -----------------------------------------------------------------------------------
-- File Name    : tf_usage_01.sql
-- Description  : Displays information about all tempfiles.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tf_usage_01.sql
-- Last Modified: 29/10/2012
-- -----------------------------------------------------------------------------------
SET LINE 120
COLUMN TEMP_FILE FORMAT a60	
COLUMN TABLESPACE_NAME FORMAT a20
SELECT  FILE_ID, FILE_NAME AS TEMP_FILE, TABLESPACE_NAME , BYTES/1024/1024 MBYTES, MAXBYTES/1024/1024 AS MAXBYTES, AUTOEXTENSIBLE
FROM DBA_TEMP_FILES;
