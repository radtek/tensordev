-- -----------------------------------------------------------------------------------
-- File Name    : db_redo_user.sql
-- Description  : Identify users generating more redo
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_redo_user.sql
-- Last Modified: 07/07/2016
-- -----------------------------------------------------------------------------------
col machine for a15 
col username for a10 
col redo_MB for 999G990 heading “Redo |Size MB”
column sid_serial for a13; 
  
select b.inst_id,  
       lpad((b.SID || ‘,’ || lpad(b.serial#,5)),11) sid_serial,  
       b.username,  
       machine,  
       b.osuser,  
       b.status,  
       a.redo_mb   
from (select n.inst_id, sid,  
             round(value/1024/1024) redo_mb 
        from gv$statname n, gv$sesstat s 
        where n.inst_id=s.inst_id 
              and n.name = ‘redo size’
              and s.statistic# = n.statistic# 
        order by value desc
     ) a, 
     gv$session b 
where b.inst_id=a.inst_id  and a.sid = b.sid  and   rownum <= 10  and b.username is not null;
