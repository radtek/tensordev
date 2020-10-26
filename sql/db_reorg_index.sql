-- -----------------------------------------------------------------------------------
-- File Name    : db_reorg_index.sql
-- Description  : Select para selecionar os indices de uma determinada tablespace e 
--                movê-las a outra
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_reorg_index.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT 'ALTER INDEX '||OWNER||'.'||INDEX_NAME||' REBUILD TABLESPACE TBS_REORG STORAGE(INITIAL 10K);'
FROM DBA_INDEXES I
WHERE TABLESPACE_NAME = '&&tablespace_name';
