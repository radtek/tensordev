-- -----------------------------------------------------------------------------------
-- File Name    : db_end_backup.sql
-- Description  : Comando que verifica as tbs que estao em BEGIN BKP e ja monta o SQL 
--                para alterá-los
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_end_backup.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select distinct 'alter database datafile '''||NAME||''' end backup;' from v$backup b, v$datafile d 
where d.file#=b.file# and b.status='ACTIVE';
