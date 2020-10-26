-- -----------------------------------------------------------------------------------
-- File Name    : db_pga_information_01.sql
-- Description  : Consulta estatisticas de consumo de memoria PGA por sessao
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_pga_information_01.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT    nvl(username,'TOTAL') as username, 
          COUNT(1) total,
          round(sum(value/1024/1024),2) mbytes
FROM      v$statname n, 
          v$session s, 
          v$sesstat t
WHERE     s.sid=t.sid
AND       n.statistic#=t.statistic#
AND       s.type='USER'
AND       s.username IS NOT NULL
AND       n.name = 'session pga memory'
GROUP BY  ROLLUP (username);
