-- -----------------------------------------------------------------------------------
-- File Name    : process_long_operations.sql
-- Description  : Verica os processos de longa duração que estao ativos no banco de 
--                dados 
-- Requirements : Access to the DBA views.
-- Call Syntax  : @process_long_operations.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINES 180
SET PAGES 600
COL "SID / SERIAL" FORMAT A12
COL OSUSER FORMAT A10
COL USERNAME FORMAT A16
COL OPNAME FORMAT A30
COL SPID FORMAT A8
SELECT CHR(39)||TO_CHAR(S.SID)||','||TO_CHAR(S.SERIAL#)||CHR(39) "SID / SERIAL", 
       S.USERNAME, 
	   S.OSUSER, 
	   P.SPID, 
	   SL.OPNAME, 
	   TO_CHAR(SL.START_TIME, 'DD/MM/YYYY HH24:MI:SS') AS STARTED, 
	   TO_CHAR(SYSDATE + (TIME_REMAINING/3600/24),'DD/MM/YYYY HH24:MI:SS') PREVISAO,
       (SL.SOFAR/SL.TOTALWORK)*100 AS PCT_COMPLETED, S.SQL_ADDRESS,
	   SL.SQL_ID
FROM GV$SESSION_LONGOPS SL, 
     GV$SESSION S, 
	 GV$PROCESS P
WHERE SL.INST_ID = S.INST_ID
  AND S.SQL_ID = SL.SQL_ID
  AND P.INST_ID = SL.INST_ID
  AND SL.SID= S.SID AND SL.SERIAL#=S.SERIAL#
  AND (SOFAR/TOTALWORK)*100 < 100
  AND TOTALWORK > 0
  AND S.PADDR = P.ADDR
ORDER BY STARTED DESC;
