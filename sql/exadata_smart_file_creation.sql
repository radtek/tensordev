-- -----------------------------------------------------------------------------------
-- File Name    : exadata_smart_file_creation.sql
-- Description  : This query shows the operations that resulted in the cell smart file  
--                creation wait event
-- Requirements : Access to the DBA views.
-- Call Syntax  : @exadata_smart_file_creation.sql
-- Last Modified: 09/09/2015
-- -----------------------------------------------------------------------------------
set lines 180
set pages 50000

col event format a40
col operation format a60

select event, operation, count(*) 
from (select sql_id, event, sql_plan_operation||' '||sql_plan_options operation
      from DBA_HIST_ACTIVE_SESS_HISTORY
	  where event like 'cell smart file%')
group by operation, event
order by 3 desc;

