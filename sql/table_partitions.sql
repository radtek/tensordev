-- -----------------------------------------------------------------------------------
-- File Name    : table_partitions.sql
-- Description  : Informacoes de tabelas particionadas
-- Requirements : Access to the DBA views.
-- Call Syntax  : @table_partitions.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT table_name, partition_name, tablespace_name, last_analyzed, num_rows
FROM dba_tab_partitions
WHERE table_name = '&&table_name';
