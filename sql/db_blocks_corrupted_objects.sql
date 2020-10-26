-- -----------------------------------------------------------------------------------
-- File Name    : db_blocks_corrupted_objects.sql
-- Description  : Verifying objects into corrupted blocks in the database
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_blocks_corrupted_objects.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT segment_name, segment_type, owner, tablespace_name
FROM sys.dba_extents
WHERE file_id = &&file_id
AND 1028849 BETWEEN block_id and block_id + blocks - 1;
