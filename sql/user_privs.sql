-- -----------------------------------------------------------------------------------
-- File Name    : user_privs.sql
-- Description  : Mostrar provilegios a um determinado usuario
-- Requirements : Access to the DBA views.
-- Call Syntax  : @user_privs.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select
  lpad(' ', 2*level) || granted_role "User, his roles and privileges"
from
  (
  /* THE USERS */
    select 
      null     grantee, 
      username granted_role
    from 
      dba_users
    where
      username like upper('%&enter_username%')
  /* THE ROLES TO ROLES RELATIONS */ 
  union
    select 
      grantee,
      granted_role
    from
      dba_role_privs
  /* THE ROLES TO PRIVILEGE RELATIONS */ 
  union
    select
      grantee,
      privilege
    from
      dba_sys_privs
  )
start with grantee is null
connect by grantee = prior granted_role;
