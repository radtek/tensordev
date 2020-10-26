-- -----------------------------------------------------------------------------------
-- File Name    : df_usage_02.sql
-- Description  : Verificando espacos livres no final dos datafiles, por tablespace, 
--                para redimensionamento a um tamanho menor.
-- Requirements : Access to the DBA views.
-- Call Syntax  : df_usage_02.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set pagesize 9999

column file_name format a80;

select 'alter database datafile '''||a.file_name||''' resize '||round((((b.maximum+c.blocks-1)*d.db_block_size/1024/1024))+1)||'M;'
from dba_data_files a,
    (select file_id,max(block_id) maximum
     from dba_extents
     group by file_id) b,
	 dba_extents c,
	(select value db_block_size
     from v$parameter
     where name='db_block_size') d
where a.file_id = b.file_id
--and a.tablespace_name = 'USERS'
  and c.file_id = b.file_id
  and c.block_id = b.maximum
order by a.tablespace_name, a.file_name;
