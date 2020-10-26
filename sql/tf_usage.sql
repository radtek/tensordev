-- -----------------------------------------------------------------------------------
-- File Name    : tf_usage.sql
-- Description  : Displays information about tempfiles.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tf_usage.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINE 180

UNDEFINE TABLESPACE

COLUMN TEMP_FILE FORMAT a70	
COLUMN TABLESPACE_NAME FORMAT a20

SELECT FILE_ID,
       FILE_NAME AS TEMP_FILE,
       TABLESPACE_NAME,
       BYTES / 1024 / 1024 MBYTES,
       MAXBYTES / 1024 / 1024 AS MAXBYTES,
       AUTOEXTENSIBLE
  FROM DBA_TEMP_FILES
 WHERE TABLESPACE_NAME = '&&TABLESPACE';
