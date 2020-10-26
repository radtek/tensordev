-- -----------------------------------------------------------------------------------
-- File Name    : df_usage_01.sql
-- Description  : Verificando espacos livres no final dos datafiles, por tablespace, 
--                para redimensionamento a um tamanho menor.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @df_usage_01.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
COLUMN tablespace_name FORMAT a30
COLUMN file_name FORMAT a80
COLUMN free_mb format 9999999.99
COLUMN tam_mb format 9999999.99
set pagesize 150
set linesize 300

select * from (
select a.tablespace_name, df.file_name, df.bytes/1024/1024 tam_mb, a.bytes/1024/1024 free_mb
from dba_data_files df,
     dba_free_space a, 
     (select b.tablespace_name, b.file_id, max(b.block_id) block_id
        from dba_free_space b
       group by b.tablespace_name, b.file_id) x
where a.tablespace_name = x.tablespace_name 
  and a.file_id = x.file_id 
  and a.block_id = x.block_id
  and df.tablespace_name = x.tablespace_name
  and df.file_id = x.file_id
 order by 4 desc
) where rownum <= 100;
