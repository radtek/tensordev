-- -----------------------------------------------------------------------------------
-- File Name    : db_invalid_indexes.sql
-- Description  : Database invalid indexes
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_invalid_indexes.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set pages 10000
select owner, index_name, index_type, table_name, status
from dba_indexes
where STATUS not in ('VALID','N/A')
order by owner;
