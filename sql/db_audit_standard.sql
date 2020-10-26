-- -----------------------------------------------------------------------------------
-- File Name    : db_audit_standard.sql
-- Description  : Database auditing information (only if auditing is enabled)
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_audit_standard
-- Last Modified: 23/09/2013
-- -----------------------------------------------------------------------------------

prompt
prompt Para listar todos os owners, digite TODOS ou senao entre com o nome especifico do owner
prompt

undefine owner

COLUMN   username             FORMAT A10
COLUMN   terminal             FORMAT A30
COLUMN   userhost             FORMAT A30
COLUMN   owner                FORMAT A10
COLUMN   obj_name             FORMAT A10
COLUMN   extended_timestamp   FORMAT A35
COLUMN   action_name          FORMAT A20

SELECT username,
       terminal,
       userhost,
       extended_timestamp,
       owner,
       obj_name,
       action_name
FROM   dba_audit_trail
WHERE  owner = DECODE('&&owner', 'TODOS', owner, '&owner')
ORDER BY extended_timestamp DESC;
