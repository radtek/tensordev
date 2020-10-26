-- -----------------------------------------------------------------------------------
-- File Name    : process_top_20_01.sql
-- Description  : Verifica os 20 top process ativos no banco de dados
-- Requirements : Access to the DBA views.
-- Call Syntax  : @process_top_20_01.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set linesize 300
set pagesize 200
col QUERY for a100
select a.* from
(select   nvl(ss.USERNAME,'ORACLE PROC') "User/Process",
         se.SID Sessao,
         ss.serial#,
         ss.status,
         VALUE,
    sql_text query
from     sys.v_$session ss, sys.v_$sesstat se, sys.v_$statname sn, v$sqlarea sa
where    se.STATISTIC# = sn.STATISTIC#
and      NAME like '%CPU used by this session%'
and      se.SID = ss.SID
and      value > 100
and         sa.address = ss.sql_address
and      ss.status='ACTIVE'
order by VALUE desc) a
Where rownum < 21
/
