-- -----------------------------------------------------------------------------------
-- File Name    : user_creation_10g.sql
-- Description  : Verificando Usuario e permissoes - Montando o SQL para que possa ser 
--                utilizado a criacao de outro usuario com os mesmos padroes
-- Requirements : Access to the DBA views.
-- Call Syntax  : @user_creation_10g.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set linesize 175
set pagesize 10000
undefine username
SELECT
    LINHA
FROM
    (
      select
          USERNAME,'CREATE USER ' || USERNAME || ' IDENTIFIED BY VALUES '''|| PASSWORD || ''' DEFAULT TABLESPACE ' || DEFAULT_TABLESPACE || ' PROFILE ' || PROFILE || ';' Linha
      from
          dba_users
      UNION all
	  select 
		  role, 'CREATE ROLE ' || ROLE || ';'
	  from
		  dba_roles
	  union all
      SELECT
          USERNAME,'ALTER USER ' || USERNAME || ' QUOTA ' || decode(max_bytes,-1,'UNLIMITED',to_char(max_bytes)) || ' ON ' || TABLESPACE_NAME || ';' Linha
      FROM
          dba_ts_quotas
      UNION all
      select
          GRANTEE,'GRANT ' || GRANTED_ROLE || ' TO ' || GRANTEE || decode(admin_option,'YES','') || ';' Linha
      from
        dba_role_privs
      UNION all
      select
          GRANTEE,'GRANT ' || PRIVILEGE || ' TO ' || GRANTEE || decode(admin_option,'YES',' WITH ADMIN OPTION','') || ';' Linha
      from
        dba_sys_privs
      UNION all
      select
          GRANTEE,'GRANT ' || PRIVILEGE || ' ON ' || owner || '.' || table_name || ' TO ' || GRANTEE || decode(GRANTABLE,'YES',' WITH GRANT OPTION','') || ';' Linha
      from
        dba_tab_privs
     )
where
  username = '&&username';
