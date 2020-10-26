-- -----------------------------------------------------------------------------------
-- File Name    : db_sessions_usage_history.sql
-- Description  : Displays history information about database sessions and proceses 
--                consumption.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_sessions_usage_history.sql
-- Last Modified: 03/04/2014
-- -----------------------------------------------------------------------------------
SET lines 180 
SET pages 5000

UNDEFINE Data_Hora_Inicial
UNDEFINE Data_Hora_Final

PROMPT Digite a data e hora inicial e final para analise, no formato dd/mm/yyyy HH24:mi:ss. Por exemplo = 03/04/2014 11:00:00

SELECT rl.snap_id,
       to_char(s.begin_interval_time, 'dd/mm/yyyy HH24:mi:ss') as "Inicio Snapshot", 
	   to_char(s.end_interval_time, 'dd/mm/yyyy HH24:mi:ss') as "Final Snapshot",
       rl.instance_number as "Instancia", 
	   rl.resource_name, 
	   rl.current_utilization,
       rl.max_utilization
FROM dba_hist_resource_limit rl, dba_hist_snapshot s
WHERE s.snap_id = rl.snap_id 
  AND rl.resource_name in ('sessions','processes')
  AND s.begin_interval_time BETWEEN to_date('&&Data_Hora_Inicial','dd/mm/yyyy HH24:mi:ss') AND to_date('&&Data_Hora_Final','dd/mm/yyyy HH24:mi:ss')
ORDER BY s.begin_interval_time, rl.instance_number
/
