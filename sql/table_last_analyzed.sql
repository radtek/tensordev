-- -----------------------------------------------------------------------------------
-- File Name    : table_last_analyzed.sql
-- Description  : Displays tables from a specific schema that are lacking analyzes
-- Requirements : Access to the DBA views.
-- Call Syntax  : @table_last_analyzed.sql
-- Last Modified: 05/04/2012
-- -----------------------------------------------------------------------------------

set lines 180
col owner for a20
prompt Entre com valores para schema e quantidade de dias para saber quais tabelas estão necessitando de ANALYZE
select a.owner, a.tablespace_name, a.table_name, a.last_analyzed, b.bytes/1024/1024 MBYTES
from dba_tables a , (select segment_name, bytes
                     from dba_segments
                    ) b
where a.table_name = b.segment_name
     and owner = '&&schema'
     and a.last_analyzed < sysdate-&&dias
order by a.last_analyzed desc;
