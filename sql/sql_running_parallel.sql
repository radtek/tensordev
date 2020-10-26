-- -----------------------------------------------------------------------------------
-- File Name    : sql_running_parallel.sql
-- Description  : Identifying running with parallel processes
-- Requirements : Access to the DBA views.
-- Call Syntax  : @sql_running_parallel.sql
-- Last Modified: 19/12/2012
-- -----------------------------------------------------------------------------------

col username for a12
col "QC SID" for A6
col SID for A6
col "QC/Slave" for A10
col "Requested DOP" for 9999
col "Actual DOP" for 9999
col "slave set" for A10
set pages 100

prompt 
prompt QC/Slave      -> Instance number on which the parallel coordinator is running
prompt Slave Set     -> The logical set of servers to which this cluster database process belongs. A single server group will have at most two server sets
prompt SID           -> Session identifier
prompt QC SID        -> Session identifier runnning de parallel query
prompt Requested DOP -> Degree of parallelism that was requested by the user when the statement was issued and prior to any resource, multi-user, or load balancing reductions
prompt Actual DOP    -> Degree of parallelism being used by the server set
prompt

select decode(px.qcinst_id,NULL,username,
       ' - '||lower(substr(s.program,length(s.program)-4,4) ) ) "Username",
       decode(px.qcinst_id,NULL, 'QC', '(Slave)') "QC/Slave" ,
       to_char( px.server_set) "Slave Set",
       to_char(s.sid) "SID",
       decode(px.qcinst_id, NULL ,to_char(s.sid) ,px.qcsid) "QC SID",
       px.req_degree "Requested DOP",
       px.degree "Actual DOP"
from
       v$px_session px,
       v$session s
where
       px.sid=s.sid (+)
   and px.serial#=s.serial#
order  by 5 , 1 desc
/
