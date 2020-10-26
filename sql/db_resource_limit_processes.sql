-- -----------------------------------------------------------------------------------
-- File Name    : db_resource_limit_processes.sql
-- Description  : Verica quantidades de processes parametrizados nas instancias e %
--                de utilizacao
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_resource_limit_processes.sql
-- Last Modified: 07/11/2017
-- -----------------------------------------------------------------------------------

set lines 180
set pages 5000

select INSTANCE_NAME,
       RESOURCE_NAME,
       CURRENT_UTILIZATION,
       MAX_UTILIZATION,
       LIMIT_VALUE,
       round((CURRENT_UTILIZATION / LIMIT_VALUE ),2)*100 PERCENT_USAGE
from GV$INSTANCE, GV$RESOURCE_LIMIT
where GV$INSTANCE.INST_ID = GV$RESOURCE_LIMIT.INST_ID
  and RESOURCE_NAME = 'processes'
order by INSTANCE_NAME;
