-- -----------------------------------------------------------------------------------
-- File Name    : tables_locked.sql
-- Description  : It shows information about the tables being locked by the sessions
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tables_locked.sql
-- Last Modified: 18/10/2015
-- -----------------------------------------------------------------------------------

column oracle_username format a15
column os_user_name format a15
column object_name format a37
column object_type format a37

SELECT A.SESSION_ID,
       A.ORACLE_USERNAME,
       A.OS_USER_NAME,
       B.OWNER "OBJECT OWNER",
       B.OBJECT_NAME,
       B.OBJECT_TYPE,
       A.LOCKED_MODE
  FROM (SELECT OBJECT_ID,
               SESSION_ID,
               ORACLE_USERNAME,
               OS_USER_NAME,
               LOCKED_MODE
          FROM GV$LOCKED_OBJECT) A,
       (SELECT OBJECT_ID, OWNER, OBJECT_NAME, OBJECT_TYPE FROM DBA_OBJECTS) B
 WHERE A.OBJECT_ID = B.OBJECT_ID
/


