-- -----------------------------------------------------------------------------------
-- File Name    : db_get_ddl_tbs_01.sql
-- Description  : Displays DDL definitions for existing tablespaces.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_get_ddl_tbs_01.sql
-- Last Modified: 27/03/2013
-- -----------------------------------------------------------------------------------
prompt
prompt To list DDL for all tablespaces type ALL or specify a tablespace name
prompt

SET ECHO OFF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SET LINESIZE 200

UNDEFINE TABLESPACE

SELECT 'CREATE TABLESPACE ' || DF.TABLESPACE_NAME || ' DATAFILE ''' || DF.FILE_NAME || ''' SIZE ' || DF.BYTES  
       || DECODE(AUTOEXTENSIBLE,'N',NULL,' AUTOEXTEND ON MAXSIZE ' || MAXBYTES) 
	   || DECODE (NEXT_EXTENT, NULL, NULL, ' NEXT ' || NEXT_EXTENT )|| ';'
FROM DBA_DATA_FILES DF, DBA_TABLESPACES T
WHERE DF.TABLESPACE_NAME=T.TABLESPACE_NAME 
  AND DF.TABLESPACE_NAME = DECODE('&&TABLESPACE', 'ALL', DF.TABLESPACE_NAME, '&TABLESPACE')
/

prompt
prompt
prompt
