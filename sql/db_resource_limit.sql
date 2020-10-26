-- -----------------------------------------------------------------------------------
-- File Name    : db_resource_limit.sql
-- Description  : Verica os recursos e limites parametrizados nas instancias
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_resource_limit.sql
-- Last Modified: 07/11/2017
-- -----------------------------------------------------------------------------------

set lines 180
set pages 5000

select INSTANCE_NAME,
       RESOURCE_NAME,
       CURRENT_UTILIZATION,
       MAX_UTILIZATION,
       LIMIT_VALUE
from GV$INSTANCE, GV$RESOURCE_LIMIT
where GV$INSTANCE.INST_ID = GV$RESOURCE_LIMIT.INST_ID
order by INSTANCE_NAME;


