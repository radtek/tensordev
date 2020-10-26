-- -----------------------------------------------------------------------------------
-- File Name    : db_tablespace_segments.sql
-- Description  : Verificação de extents de um segmento em uma determinada tablespace
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_tablespace_segments.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select * 
from (select bytes/1024/1024 from dba_free_space
      where tablespace_name = '&&tablespace_name'
      order by 1 desc) 
where rownum <= 10;
