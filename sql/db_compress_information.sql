-- -----------------------------------------------------------------------------------
-- File Name    : db_compress_information.sql
-- Description  : SELECT to find out tables with correct datafiles to compress and 
--                scripting for execution
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_compress_information.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select 'ALTER TABLE ' ||owner|| '.' ||table_name|| ' MOVE COMPRESS FOR OLTP;' as SCRIPT_TO_COMPRESS_TABLES
from dba_tab_columns  
where owner in ('PROD_JD','NETSALES','GED') 
  and data_type not in ('CLOB','RAW','LONG RAW','XMLTYPE','NCLOB','BLOB')
group by owner, table_name
order by owner;
