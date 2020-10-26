-- -----------------------------------------------------------------------------------
-- File Name    : db_partitioned_tables.sql
-- Description  : Shows database partitioned tables by owner ( Not SYS and SYSTEM )
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_partitioned_tables.sql
-- Last Modified: 03/04/2012
-- -----------------------------------------------------------------------------------

select owner, table_name, num_rows, COMPRESSION, compress_for, partitioned as PARTITIONED
from dba_tables
where partitioned = 'YES'
    and owner not in ('SYS','SYSTEM')
order by owner;
