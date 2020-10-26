-- -----------------------------------------------------------------------------------
-- File Name    : db_db_links.sql
-- Description  : Verificacao de DB_LINKS de uma determinada base de dados
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_db_links.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set linesize 500
set pagesize 1000
col DB_LINK for a40
col HOST for a20
col USERNAME format a15
select OWNER, DB_LINK, USERNAME, HOST,
to_char(CREATED,'DD/MM/YYYY HH24:MI:SS') Criacao
from dba_db_links
--where DB_LINK = 'BASECLARO'
order by OWNER, DB_LINK;
