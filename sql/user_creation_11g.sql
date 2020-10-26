-- -----------------------------------------------------------------------------------
-- File Name    : user_creation_11g.sql
-- Description  : Montando o SQL para que possa ser utilizado a criacao de outro 
--                usuario com os mesmos padroes. Deve ser executado como SYS
-- Requirements : Access to the DBA views.
-- Call Syntax  : @user_creation_11g.sql
-- Last Modified: 27/03/2013
-- -----------------------------------------------------------------------------------

SET LINESIZE 175
SET PAGESIZE 10000

UNDEFINE USERNAME

SELECT
    CREATE_USER
FROM
    (
      SELECT A.USERNAME, 'CREATE USER ' || A.USERNAME || ' IDENTIFIED BY VALUES '''|| B.SPARE4 || ''' DEFAULT TABLESPACE ' || A.DEFAULT_TABLESPACE || ' PROFILE ' || A.PROFILE || ';' CREATE_USER
      FROM DBA_USERS A, SYS.USER$ B
      WHERE A.USERNAME = B.NAME
      UNION ALL
	  SELECT 
		  ROLE, 'CREATE ROLE ' || ROLE || ';'
	  FROM
		  DBA_ROLES
	  UNION ALL
      SELECT
          USERNAME,'ALTER USER ' || USERNAME || ' QUOTA ' || DECODE(MAX_BYTES,-1,'UNLIMITED',TO_CHAR(MAX_BYTES)) || ' ON ' || TABLESPACE_NAME || ';' LINHA
      FROM
          DBA_TS_QUOTAS
      UNION ALL
      SELECT
          GRANTEE,'GRANT ' || GRANTED_ROLE || ' TO ' || GRANTEE || DECODE(ADMIN_OPTION,'YES','') || ';' LINHA
      FROM
        DBA_ROLE_PRIVS
      UNION ALL
      SELECT
          GRANTEE,'GRANT ' || PRIVILEGE || ' TO ' || GRANTEE || DECODE(ADMIN_OPTION,'YES',' WITH ADMIN OPTION','') || ';' LINHA
      FROM
        DBA_SYS_PRIVS
      UNION ALL
      SELECT
          GRANTEE,'GRANT ' || PRIVILEGE || ' ON ' || OWNER || '.' || TABLE_NAME || ' TO ' || GRANTEE || DECODE(GRANTABLE,'YES',' WITH GRANT OPTION','') || ';' LINHA
      FROM
        DBA_TAB_PRIVS
     )
WHERE
  USERNAME = '&&USERNAME'
/
