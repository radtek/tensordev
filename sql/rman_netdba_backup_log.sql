-- -----------------------------------------------------------------------------------
-- File Name    : rman_netdba_backup_log.sql
-- Description  : Verifica o status dos backups dos bancos de dados da NET
-- Requirements : Access to the NETDBA tables.
-- Call Syntax  : @rman_netdba_backup_log.sql
-- Last Modified: 10/04/2014
-- -----------------------------------------------------------------------------------

SET LINESIZE  180
SET PAGESIZE  10000
SET COLSEP |

UNDEFINE dias

COL DB_NAME FORMAT a12
COL STATUS  FORMAT a24

PROMPT
PROMPT DIGITE O NUMERO DE DIAS DESEJADOS NA CONSULTA. POR EXEMPLO: PARA UMA SEMANA, DIGITE 7
PROMPT

SELECT distinct(DB_NAME),
       to_date(START_TIME, 'dd/mm/yyyy HH24:MI') as "Startup time",
	   STATUS,
	   INPUT_TYPE
FROM NETDBA.BACKUP_LOG
WHERE START_TIME >= sysdate - (&dias)
GROUP BY DB_NAME, START_TIME, STATUS, INPUT_TYPE
ORDER BY 2 DESC
/

