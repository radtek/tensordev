-- -----------------------------------------------------------------------------------
-- File Name    : db_drop_objects.sql
-- Description  : Dropar os objetos de um determinado owner
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_drop_objects.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 180
set pages 10000

PROMPT
PROMPT Geracao de script para dropar os objetos de um determinado owner
PROMPT

undefine owner

select
'drop '||object_type||' '||owner||'.'||object_name||' CASCADE CONSTRAINTS;'
from dba_objects
where object_type in ('FUNCTION','LIBRARY','MATERIALIZED VIEW','PACKAGE','PROCEDURE','SEQUENCE','TABLE','VIEW','SYNONYM','TYPE','JAVA CLASS','JAVA SOURCE')
and owner in ('&&owner')
order by owner, object_type, object_name;
