-- -----------------------------------------------------------------------------------
-- File Name    : rac_information.sql
-- Description  : Verificacao do status das instancias do RAC
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rac_information.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------

SET LINES 175 PAGES 5000 COLSEP |

COLUMN INSTANCE_NAME    FORMAT A16
COLUMN STARTUP_TIME     FORMAT A20
COLUMN DATABASE_STATUS  FORMAT A16
COLUMN "DATA/HORA"      FORMAT A20
COLUMN HOST_NAME        FORMAT A22
COLUMN OPEN_MODE        FORMAT A14
SELECT
	INSTANCE_NAME || CASE WHEN INSTANCE_NAME = (SELECT INSTANCE_NAME FROM V$INSTANCE) THEN ' *' ELSE '' END
	INSTANCE_NAME,
	TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS') "DATA/HORA",
	TO_CHAR(STARTUP_TIME,'DD/MM/YYYY HH24:MI:SS') STARTUP_TIME,
	HOST_NAME,
	LOGINS,
	STATUS,
	DATABASE_STATUS,
	ACTIVE_STATE,
	LOG_MODE,
	OPEN_MODE
FROM
	GV$INSTANCE,
	V$DATABASE;
