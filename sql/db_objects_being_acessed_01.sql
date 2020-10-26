-- -----------------------------------------------------------------------------------
-- File Name    : db_objects_being_acessed_01.sql
-- Description  : Lista os objetos sendo acessados por uma determinada sessao
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_objects_being_acessed_01.sql
-- Last Modified: 01/12/2012
-- -----------------------------------------------------------------------------------
set lines 180
col SID format 99999
col OWNER format a30
col OBJECT format a40
col TYPE format a20

prompt
prompt DESCOBRIR OBJETOS SENDO ACESSADO POR UMA DETERMINADA SESSAO
prompt ENTRE COM O VALOR DA SESSAO E O TIPO DO OBJETO A SER PESQUISADO
prompt

select SID, OWNER, TYPE, OBJECT
from v$access
where SID = &sid
  and TYPE like '%&type%'
order by OWNER, TYPE, OBJECT  
/
