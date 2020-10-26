-- -----------------------------------------------------------------------------------
-- File Name    : dbv.sql
-- Description  : Select para selecionar os datafiles do banco de dados ja montando o comando de DBV
-- Requirements : Access to the DBA views.
-- Call Syntax  : @dbv.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select 'dbv file=' || file_name || ' blocksize=' || b.value || ' logfile=datafile' || '.' || FILE_ID || '.log' 
from dba_data_files a, v$parameter b where b.name =  'db_block_size';
