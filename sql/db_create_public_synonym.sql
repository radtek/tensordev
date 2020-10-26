-- -----------------------------------------------------------------------------------
-- File Name    : db_create_public_synonym.sql
-- Description  : Criando Sin�nimos P�blicos para objetos de determinados usu�rios
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_create_public_synonym.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT 'CREATE PUBLIC SYNONYM '||OBJECT_NAME||' FOR '||OWNER||'.'||OBJECT_NAME||';'
FROM dba_OBJECTS
WHERE OBJECT_TYPE IN ('PROCEDURE','FUCTION','PACKAGE','TABLE','VIEW','SEQUENCE')
and owner = '&&owner';
