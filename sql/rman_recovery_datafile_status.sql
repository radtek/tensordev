-- -----------------------------------------------------------------------------------
-- File Name    : rman_recovery_datafile_status.sql
-- Description  : Displays the recovery status of each datafile
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rman_recovery_datafile_status.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 500
SET FEEDBACK OFF

col Datafile format a80
col Status   format a20

SELECT Substr(a.name,1,60) "Datafile",
       b.status "Status"
FROM   v$datafile a,
       v$backup b
WHERE  a.file# = b.file#;

SET PAGESIZE 14
SET FEEDBACK ON
