-- -----------------------------------------------------------------------------------
-- File Name    : db_indexes.sql
-- Description  : Database indexes
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_indexes.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set pages 10000
select owner, index_name, index_type, table_name, status
from dba_indexes
order by owner;
