-- -----------------------------------------------------------------------------------
-- File Name    : db_blocks_corrupted_objects_size.sql
-- Description  : Verifying objects sizes into corrupted blocks in the database
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_blocks_corrupted_objects_size.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select sum(bytes) / 1024 / 1024 / 1024 "Tamanho do objeto em Gb"
from dba_segments
where owner = '&&owner'
and segment_name = '&&segment_name'
and segment_type = '&&segment_type'
