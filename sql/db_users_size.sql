-- -----------------------------------------------------------------------------------
-- File Name    : db_users_size.sql
-- Description  : Displays information about all database users with size information
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_users_size.sql
-- Last Modified: 10/07/2014
-- -----------------------------------------------------------------------------------
set lines 180
set pages 10000
set colsep |
col username for a30
col account_status for a30
col profile for a30
col created for a10
col default_tablespace for a30
col temporary_tablespace for a30

SELECT a.username,
       a.account_status,
	   to_char(a.created, 'DD/MM/YYYY') CREATED,
	   a.profile,
	   a.default_tablespace TBS_DEFAULT,
	   a.temporary_tablespace TEMP_TBS,
	   round(sum(b.bytes)/1024/1024,2) as "MBytes"
FROM dba_users a, dba_segments b
WHERE a.username = b.owner
GROUP BY a.username, a.account_status, a.created, a.profile, a.default_tablespace, a.temporary_tablespace
ORDER BY a.username
/
