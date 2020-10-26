-- -----------------------------------------------------------------------------------
-- File Name    : db_sessions.sql
-- Description  : Displays information about database sessions.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_sessions.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINES 180;
SET PAGES 10000;
SET COLSEP |;

COL      USERNAME        FORMAT A20
COL      SID             FORMAT 99999
COL      SERIAL          FORMAT 99999
COL      STATUS          FORMAT A8
COL      OSUSER          FORMAT A16
COL      PROGRAM         FORMAT A40
COL      MACHINE         FORMAT A20
COL      LOGON_TIME      FORMAT A20

SELECT USERNAME,
       SID,
	   SERIAL# SERIAL,
	   STATUS,
	   OSUSER,
	   SUBSTR(PROGRAM,1,39) PROGRAM,
       SUBSTR(MACHINE,1,19) MACHINE,
	   TO_CHAR(LOGON_TIME,'DD-MON-RRRR HH24:MI:SS') LOGON_TIME,
	   SQL_ID
FROM V$SESSION 
WHERE USERNAME <> ' '
-- AND USERNAME = 'SVC_COFRE'
ORDER BY LOGON_TIME DESC
/
