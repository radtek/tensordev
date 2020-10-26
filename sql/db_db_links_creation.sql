-- -----------------------------------------------------------------------------------
-- File Name    : db_db_links_creation.sql
-- Description  : Selecionar os DBLinks de uma determinada base já gerando o script 
--                para criação dos mesmos em outra base
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_db_links_creation.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select owner_name, 'create database link '||NAME||'
connect to '||userid ||'
identified by values '||''''||passwordx||''''||' using '||''''||host||''''||';'
from SYS.KU$_DBLINK_VIEW;


select owner_name,
       'conn ' || owner_name || '/' ||i.instance_name||'_xpto_' || owner_name || '@' ||i.instance_name||'',
       'drop database link ' || NAME || ';',
       'create database link ' || NAME || '
  connect to ' || userid || '
identified by values ' || '''' || passwordx || '''' || ' using ' || '''' || host || '''' || ';'
  from SYS.KU$_DBLINK_VIEW d, v$instance i
order by owner_name
