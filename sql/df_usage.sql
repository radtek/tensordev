-- -----------------------------------------------------------------------------------
-- File Name    : df_usage.sql
-- Description  : Displays information about datafiles.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @df_usage.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
prompt
prompt
prompt To list all datafiles from the database type ALL or type a name of a tablespace to list specific datafiles
prompt
prompt

COL TABLESPACE_NAME FORMAT A24
COL FILE_NAME FORMAT A80
COL "CREATED IN" FORMAT A20

UNDEFINE TABLESPACE

SET LINESIZE 180 
SET PAGESIZE 1000
SELECT A.TABLESPACE_NAME, 
       A.FILE_NAME, 
	   ROUND(A.BYTES/1024/1024,2) AS MBYTES, 
	   ROUND(A.MAXBYTES/1024/1024,2) AS MAXBYTES, 
	   A.AUTOEXTENSIBLE, 
	   TO_CHAR(B.CREATION_TIME, 'DD/MM/YYYY HH24:MM:SS') AS "CREATED IN"
FROM DBA_DATA_FILES A, V$DATAFILE B
WHERE A.FILE_ID = B.FILE#
  AND A.TABLESPACE_NAME = DECODE('&&TABLESPACE', 'ALL', A.TABLESPACE_NAME, '&TABLESPACE')
ORDER BY A.TABLESPACE_NAME, B.CREATION_TIME DESC;
