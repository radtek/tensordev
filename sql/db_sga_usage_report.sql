-- -----------------------------------------------------------------------------------
-- File Name    : db_sga_usage_report.sql
-- Description  : Exibe total de memória, total de memória usada e percentual de 
--                memória livre de cada área de memória da SGA inclusive o total da SGA
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_sga_usage_report.sql
-- Last Modified: 06/05/2014
-- -----------------------------------------------------------------------------------

break on report
compute sum of mb on report
compute sum of inuse on report
set pagesize 50
col mb format 999,999
col inuse format 999,999
select name,
       round(sum(mb),1) mb,
       round(sum(inuse),1) inuse
  from (select case when name = 'buffer_cache'
                    then 'db_cache_size'
                    when name = 'log_buffer'
                    then 'log_buffer'
                    else pool
                end name,
                bytes/1024/1024 mb,
                case when name <> 'free memory'
                     then bytes/1024/1024
                end inuse
           from v$sgastat
       )
 group by name
 order by mb desc
/
