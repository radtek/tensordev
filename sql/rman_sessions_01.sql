-- -----------------------------------------------------------------------------------
-- File Name    : rman_sessions_01.sql
-- Description  : Simple script for monitoring the RMAN sessions in progress in the db
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rman_sessions_01.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set pagesize 10000
set linesize 175
column inicio format a17
column Previsao_Termino format a17
column opname format a30
select
vs.sid,
vs.serial#,
vs.username Usuario,
vs.status,
vsl.opname,
to_char(Start_Time,'DD/MM/YYYY HH24:MI') Inicio,
case (totalwork*sofar) when 0 then '' else to_char(start_time+(sysdate-Start_Time)/(sofar/totalwork),'DD/MM/YYYY HH24:MI') end Previsao_Termino,
TotalWork Total,
Sofar Processado,
case (totalwork*sofar) when 0 then 0 else round(sofar/totalwork*100,2) end Perc_Processado
from
gv$session_longops vsl
join gv$session vs on vsl.sid = vs.sid and vs.inst_id = vsl.inst_id
where
totalwork <> sofar;
