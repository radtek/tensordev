-- -----------------------------------------------------------------------------------
-- File Name    : db_user_operations.sql
-- Description  : Lista todos os usuarios e o qual a operação e programa sendo executado 
--                no banco
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_user_operations.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 180
set pages 5000
col username format a20
col sid format 9999
col serial# format 9999
col program format a40
col command format a20
col machine format a30
col logon format a20
select 
   substr(s.username,1,18) username,
   s.sid,
   s.serial#,
   substr(s.program,1,30) program,
   decode(s.command,
       0,'No Command',
       1,'Create Table',
       2,'Insert',
       3,'Select',
       6,'Update',
       7,'Delete',
       9,'Create Index',
      15,'Alter Table',
      21,'Create View',
      23,'Validate Index',
      35,'Alter Database',
      39,'Create Tablespace',
      41,'Drop Tablespace',
      40,'Alter Tablespace',
      53,'Drop User',
      62,'Analyze Table',
      63,'Analyze Index',
      s.command||': Other') command,
       TO_CHAR(s.logon_time,'DD-MON-RRRR HH24:MI:SS') logon,
       s.machine
from 
     v$session     s,
     v$process     p,
     v$transaction t,
     v$rollstat    r,
     v$rollname    n
where s.paddr = p.addr
and   s.taddr = t.addr (+)
and   t.xidusn = r.usn (+)
and   r.usn = n.usn (+)
and   s.username <> ' '
order by logon desc;
