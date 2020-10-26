-- -----------------------------------------------------------------------------------
-- File Name    : process_detail.sql
-- Description  : Show Oracle process detail
-- Requirements : Access to the DBA views.
-- Call Syntax  : @process_detail.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set line 120
set pagesize 20
col username format a20
col program format a45
col command format a25

select
   s.sid,
   s.status,
   s.username,
   s.program,
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
      44,'Commit',
      45,'Rollback',
      47,'PL/SQL EXECUTE',
      53,'Drop User',
      62,'Analyze Table',
      63,'Analyze Index',
      85,'TRUNCATE TABLE',
         s.command||': Other') command
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
order by 1;
