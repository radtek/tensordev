-- -----------------------------------------------------------------------------------
-- File Name    : table_locks.sql
-- Description  : Lista os processos em estado de espera, o tipo de lock solicitado
--                e o processo que esta segurando a fila de lock
-- Requirements : Access to the DBA views.
-- Call Syntax  : @table_locks.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
prompt
prompt
prompt LISTA OS PROCESSOS EM ESTADO DE ESPERA, O TIPO DE LOCK SOLICITADO E O PROCESSO QUE ESTA SEGURANDO A FILA DE LOCK.
prompt
prompt

column username  format a15
column sid       format A12
column type      format A4
column lmode     format 990   heading 'HELD'
column request   format 990   heading 'REQ'
column id1       format 999990
column id2       format 999990

break on id1 skip 1 dup

prompt

/*+ rule */ select  sn.username,
        sn.sid||','||sn.serial# sid,
        m.type,
        decode(m.lmode,
               0,'None',
               1,'Null',
               2,'Row Share',
               3,'Row Excl.',
               4,'Share',
               5,'S/Row Excl.',
               6,'Exclusive',
               ltrim(to_char(m.lmode,'990'))) lmode,
        decode(m.request,
               0,'None',
               1,'Null',
               2,'Row Share',
               3,'Row Excl.',
               4,'Share',
               5,'S/Row Excl.',
               6,'Exclusive',
               ltrim(to_char(m.request,'990'))) request,
        m.id1,
        m.id2,
        n.ctime,
        sn.status
  from  v$session sn,
        v$lock m,
       (select  id1,id2,max(ctime) ctime
          from  v$lock
          where request=0
          group by id1,id2) n
  where sn.sid=m.sid and
        m.id1=n.id1  and
        m.id2=n.id2  and
       (m.request!=0 or m.request!=4) and
        (m.id1,m.id2) in (
        select  s.id1,s.id2
          from  v$lock s
          where request!=0 )
  order by n.ctime,id1,id2,m.request;

clear breaks

prompt
prompt Tabelas com acesso exclusivo:
prompt

col BLOCKING_OTHERS format a15
col sid format 999999

select SESSION_ID sid,
       NAME,
       MODE_HELD,
       MODE_REQUESTED,
       BLOCKING_OTHERS
from sys.dba_dml_locks
order by session_id;
