-- -----------------------------------------------------------------------------------
-- File Name    : db_audit_fga.sql
-- Description  : Database auditing information (only if auditing is enabled)
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_audit_fga
-- Last Modified: 23/09/2013
-- -----------------------------------------------------------------------------------

prompt
prompt Para listar todas as politicas, digite TODAS ou senao entre com o nome da politica
prompt

UNDEFINE POLICY_NAME

COL  POLICY_NAME          FORMAT A14
COL  TIMESTAMP            FORMAT A14
COL  EXTENDED_TIMESTAMP   FORMAT A20
COL  DB_USER              FORMAT A10
COL  OS_USER              FORMAT A10
COL  OBJECT_SCHEMA        FORMAT A14
COL  OBJECT_NAME          FORMAT A14
COL  SQL_TEXT             FORMAT A60

SELECT POLICY_NAME,
       TIMESTAMP,
       EXTENDED_TIMESTAMP,
       DB_USER,
       OS_USER,
       OBJECT_SCHEMA,
       OBJECT_NAME,
       SQL_TEXT
  FROM DBA_FGA_AUDIT_TRAIL
 WHERE POLICY_NAME =
       DECODE('&&POLICY_NAME', 'TODAS', POLICY_NAME, '&POLICY_NAME')
 ORDER BY POLICY_NAME;
