-- -----------------------------------------------------------------------------------
-- File Name    : db_user_quotas.sql
-- Description  : Verificando usuarios e quotas no db
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_user_quotas.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------

SELECT 'ALTER USER "' || USERNAME || '" QUOTA UNLIMITED ON ' || TABLESPACE_NAME || ';' 
FROM DBA_TS_QUOTAS
WHERE USERNAME = '&&USERNAME' 
ORDER BY USERNAME;
