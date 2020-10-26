-- -----------------------------------------------------------------------------------
-- File Name    : db_rebuild_indexes.sql
-- Description  : Identificando Incides invalidos
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_rebuild_indexes.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select 'ALTER INDEX '||OWNER||'.'|| INDEX_NAME ||' REBUILD ONLINE PARALLEL 10;' 
from DBA_INDEXES 
where STATUS not in ('VALID','N/A');
