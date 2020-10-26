-- -----------------------------------------------------------------------------------
-- File Name    : user_privs_02.sql
-- Description  : Mostrar provilegios a um determinado usuario
-- Requirements : Access to the DBA views.
-- Call Syntax  : @user_privs_02.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select * from (
SELECT 'grant '|| privilege||' on '||OWNER||'.'||table_name||' to '||grantee||';' s
FROM dba_tab_privs WHERE grantee=UPPER('&USER') UNION ALL
SELECT 'grant '|| privilege||' to '||grantee||';' s
FROM  dba_sys_privs WHERE grantee=UPPER('&USER') UNION ALL
SELECT 'grant '||granted_role||' to '||grantee||';' s
FROM dba_role_privs WHERE grantee=UPPER('&USER'));
