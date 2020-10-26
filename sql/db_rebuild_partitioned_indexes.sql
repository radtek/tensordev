-- -----------------------------------------------------------------------------------
-- File Name    : db_rebuild_partitioned_indexes.sql
-- Description  : Script to rebuild partitioned indexes
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_rebuild_partitioned_indexes.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select 'ALTER INDEX '|| INDEX_NAME ||' rebuild partition ' || PARTITION_NAME ||' online parallel n;' 
from DBA_IND_PARTITIONS
where STATUS <> 'USABLE';
