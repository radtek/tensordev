-- -----------------------------------------------------------------------------------
-- File Name    : db_size.sql
-- Description  : Database sizes. Used and allocated
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_size.sql
-- Last Modified: 22/01/2013
-- -----------------------------------------------------------------------------------
SET LINES 180 COLSEP | PAGES 5000

ALTER SESSION ENABLE PARALLEL DML;

COL "DATABASE NAME" FORMAT A14
COL "DATABASE SIZE" FORMAT A14
COL "FREE SPACE" FORMAT A14
COL "USED SPACE" FORMAT A14

SELECT /*+ PARALLEL(20) */ NAME.NAME "DATABASE NAME"
,   ROUND(SUM(USED.BYTES) / 1024 / 1024 / 1024 ) || ' GB' "DATABASE SIZE"
,	ROUND(SUM(USED.BYTES) / 1024 / 1024 / 1024 ) - ROUND(FREE.P / 1024 / 1024 / 1024) || ' GB' "USED SPACE"
,	ROUND(FREE.P / 1024 / 1024 / 1024) || ' GB' "FREE SPACE"
FROM V$DATABASE NAME
,   (SELECT	BYTES
	FROM	V$DATAFILE
	UNION	ALL
	SELECT	BYTES
	FROM 	V$TEMPFILE
	UNION 	ALL
	SELECT 	BYTES
	FROM 	V$LOG) USED
,	(SELECT SUM(BYTES) AS P
	FROM DBA_FREE_SPACE) FREE
GROUP BY NAME.NAME, FREE.P
/
