-- -----------------------------------------------------------------------------------
-- File Name    : db_transactions_per_day.sql
-- Description  : Shows database transactions volume per day
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_transactions_per_day
-- Last Modified: 23/09/2013
-- -----------------------------------------------------------------------------------

set pages 100
set linesize 150

break on report
compute avg label 'Average by day' -
sum label 'Sum by day ' - of MB on report

column day format a15
column MB format 999,999,999,999

select trunc(COMPLETION_TIME) Day, trunc(sum(BLOCKS*BLOCK_SIZE)/1024/1024) MB
from v$archived_log
-- where to_char(COMPLETION_TIME, 'Day') like '%Monday%'
group by trunc(COMPLETION_TIME)
order by trunc(COMPLETION_TIME)
/

