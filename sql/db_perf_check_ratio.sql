-- -----------------------------------------------------------------------------------
-- File Name    : db_perf_check_ratio.sql
-- Description  : Reports all information about Database Ratio
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_perf_check_ratio.sql
-- Last Modified: 10/04/2012
-- -----------------------------------------------------------------------------------
column Ratio format a30
column Value format a20
TTITLE '******Hit Ratio Report*****'
--BTITLE '*****End of Report*****'

SELECT cur.inst_id, 'Buffer Cache Hit Ratio ' "Ratio", to_char(ROUND((1-(phy.value / (cur.value + con.value)))*100,2)) "Value"
FROM gv$sysstat cur, gv$sysstat con, gv$sysstat phy
WHERE cur.name = 'db block gets'
AND con.name = 'consistent gets'
AND phy.name = 'physical reads'
and phy.inst_id=1
and cur.inst_id=1
and con.inst_id=1
union all
SELECT cur.inst_id,'Buffer Cache Hit Ratio ' "Ratio", to_char(ROUND((1-(phy.value / (cur.value + con.value)))*100,2)) "Buffer Cache Hit Ratio"
FROM gv$sysstat cur, gv$sysstat con, gv$sysstat phy
WHERE cur.name = 'db block gets'
AND con.name = 'consistent gets'
AND phy.name = 'physical reads'
and phy.inst_id=2
and cur.inst_id=2
and con.inst_id=2
union
SELECT inst_id, 'Library Cache Hit Ratio ' "Ratio", to_char(Round(sum(pins) / (sum(pins)+sum(reloads)) * 100,2)) "Library Cache Hit Ratio"
FROM gv$librarycache group by inst_id
union
SELECT inst_id,'Dictionary Cache Hit Ratio ' "Ratio", to_char(ROUND ((1 - (SUM (getmisses) / SUM (gets))) * 100, 2)) "Percentage"
FROM gv$rowcache group by inst_id
union
Select inst_id, 'Get Hit Ratio ' "Ratio",to_char(round((sum(GETHITRATIO))*100,2)) "Get Hit"--, round((sum(PINHITRATIO))*100,2)"Pin Hit"
FROM GV$librarycache
where namespace in ('SQL AREA')
group by inst_id
union
Select inst_id, 'Pin Hit Ratio ' "Ratio", to_char(round((sum(PINHITRATIO))*100,2))"Pin Hit"
FROM GV$librarycache
where namespace in ('SQL AREA')
group by inst_id
union
select a.inst_id,'Soft-Parse Ratio ' "Ratio", to_char(round(100 * ((a.value - b.value) / a.value ),2)) "Soft-Parse Ratio"
from (select inst_id,value from gv$sysstat where name like 'parse count (total)') a,
(select inst_id, value from gv$sysstat where name like 'parse count (hard)') b
where a.inst_id = b.inst_id
union
select a.inst_id,'Execute Parse Ratio ' "Ratio", to_char(round(100 - ((a.value / b.value)* 100),2)) "Execute Parse Ratio"
from (Select inst_id, value from gv$sysstat where name like 'parse count (total)') a,
(select inst_id, value from gv$sysstat where name like 'execute count') b
where a.inst_id = b.inst_id
union
select a.inst_id,'Parse CPU to Elapsed Ratio ' "Ratio", to_char(round((a.value / b.value)* 100,2)) "Parse CPU to Elapsed Ratio"
from (Select inst_id, value from gv$sysstat where name like 'parse time cpu') a,
(select inst_id, value from gv$sysstat where name like 'parse time elapsed') b
where a.inst_id = b.inst_id
union
Select a.inst_id,'Chained Row Ratio ' "Ratio", to_char(round((a.val/b.val)*100,2)) "Chained Row Ratio"
from (SELECT inst_id, SUM(value) val FROM gV$SYSSTAT WHERE name = 'table fetch continued row' group by inst_id) a,
(SELECT inst_id, SUM(value) val FROM gV$SYSSTAT WHERE name IN ('table scan rows gotten', 'table fetch by rowid') group by inst_id) b
where a.inst_id = b.inst_id
union
Select inst_id,'Latch Hit Ratio ' "Ratio", to_char(round(((sum(gets) - sum(misses))/sum(gets))*100,2)) "Latch Hit Ratio"
from gv$latch
group by inst_id
union
select inst_id, metric_name, to_char(value)
from gv$sysmetric
where metric_name in ( 'Database Wait Time Ratio', 'Database CPU Time Ratio')
and intsize_csec = (select max(intsize_csec) from gv$sysmetric)
order by inst_id
/
