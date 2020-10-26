-- ----------------------------------------------------------------------------------------
-- File Name    : user_privs_01.sql
-- Description  : Displays a list of all roles and priviliges granted to the specified user
-- Requirements : Access to the DBA views.
-- Call Syntax  : @user_privs_01.sql
-- Last Modified: 02/04/2012
-- ----------------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET VERIFY OFF
SELECT a.granted_role "Role",
       a.admin_option "Adm"
FROM   user_role_privs a;
SELECT a.privilege "Privilege",
       a.admin_option "Adm"
FROM   user_sys_privs a;
              
SET VERIFY ON
