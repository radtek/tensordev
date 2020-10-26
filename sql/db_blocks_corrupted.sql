-- -----------------------------------------------------------------------------------
-- File Name    : db_blocks_corrupted.sql
-- Description  : Verifying corrupted blocks in the database
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_blocks_corrupted.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select * from V$DATABASE_BLOCK_CORRUPTION;
