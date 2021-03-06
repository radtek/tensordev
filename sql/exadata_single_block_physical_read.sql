-- -----------------------------------------------------------------------------------
-- File Name    : exadata_single_block_physical_read.sql
-- Description  : This query shows the operations that resulted in the cell single  
--                block physical read wait event
-- Requirements : Access to the DBA views.
-- Call Syntax  : @exadata_single_block_physical_read.sql
-- Last Modified: 09/09/2015
-- -----------------------------------------------------------------------------------
set lines 180
set pages 50000

col event format a40
col operation format a60

select event, operation, count(*) 
from (select sql_id, event, sql_plan_operation||' '||sql_plan_options operation
      from DBA_HIST_ACTIVE_SESS_HISTORY
	  where event like 'cell single%')
group by operation, event
order by 3 desc;

