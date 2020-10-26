-- -----------------------------------------------------------------------------------
-- File Name    : dg_last_messages.sql
-- Description  : Dataguard status messages
-- Requirements : Access to the DBA views.
-- Call Syntax  : @dg_last_messages
-- Last Modified: 31/07/2014
-- -----------------------------------------------------------------------------------
set lines 180
set pages 10000
col message for a80

SELECT FACILITY, SEVERITY, ERROR_CODE, to_char(TIMESTAMP, 'DD/MM/YYYY HH24:MM:SS')  "Data e Hora", MESSAGE
FROM ( SELECT * FROM V$DATAGUARD_STATUS ORDER BY TIMESTAMP)
WHERE ROWNUM <=5000
/
