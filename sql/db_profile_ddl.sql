-- -----------------------------------------------------------------------------------
-- File Name    : db_profile_ddl.sql
-- Description  : Displays the DDL for the specified profile(s).
-- Call Syntax  : @db_profile_ddl
-- Last Modified: 02/102/2018
-- -----------------------------------------------------------------------------------

SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

COLUMN DDL FORMAT A1000

BEGIN
   DBMS_METADATA.SET_TRANSFORM_PARAM (DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', TRUE);
   DBMS_METADATA.SET_TRANSFORM_PARAM (DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', TRUE);
END;
/

SELECT DBMS_METADATA.GET_DDL('PROFILE', PROFILE) AS PROFILE_DDL
FROM   (SELECT DISTINCT PROFILE
        FROM   DBA_PROFILES)
WHERE  PROFILE LIKE UPPER('%&1%');

SET LINESIZE 80 PAGESIZE 14 FEEDBACK ON VERIFY ON
