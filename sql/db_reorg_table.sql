-- -----------------------------------------------------------------------------------
-- File Name    : db_reorg_table.sql
-- Description  : Select para selecionar as tabelas de uma determinada tablespace e 
--                movê-las a outra
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_reorg_table.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT 'ALTER TABLE '||OWNER||'.'||TABLE_NAME||' MOVE TABLESPACE TBS_REORG STORAGE(INITIAL 10K);'
FROM DBA_TABLES I 
WHERE TABLESPACE_NAME = '&&tablespace_name';
