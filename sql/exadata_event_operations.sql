-- -----------------------------------------------------------------------------------
-- File Name    : exadata_event_operations.sql
-- Description  : This query shows cell events and the operations that caused them
-- Requirements : Access to the DBA views.
-- Call Syntax  : @exadata_event_operations.sql
-- Last Modified: 04/09/2015
-- -----------------------------------------------------------------------------------
set lines 180
set pages 50000

col event format a40
col operation format a60

select event, operation, count(*) 
from (select sql_id, event, sql_plan_operation||' '||sql_plan_options operation
      from DBA_HIST_ACTIVE_SESS_HISTORY
      where event like 'cell %')
group by operation, event
order by 1,2,3
/
