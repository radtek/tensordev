-- -----------------------------------------------------------------------------------
-- File Name    : db_services.sql
-- Description  : List services registered in the database 
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_services.sql
-- Last Modified: 22/11/2013
-- -----------------------------------------------------------------------------------
set lines 180

col SERVICE_ID        format 9999
col NAME              format a20
col NAME_HASH         format 9999999999
col NETWORK_NAME      format a20
col FAILOVER_TYPE     format a20
col FAILOVER_METHOD   format a20
col FAILOVER_RETRIES  format 9999
col GOAL              format a10

select SERVICE_ID, NAME, NAME_HASH, NETWORK_NAME, FAILOVER_TYPE, FAILOVER_METHOD, FAILOVER_RETRIES, GOAL, ENABLED as "ENABLED"
from DBA_SERVICES
/
