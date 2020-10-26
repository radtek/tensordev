-- -----------------------------------------------------------------------------------
-- File Name    : dg_arch_destination.sql
-- Description  : Dataguard archives destination information
-- Requirements : Access to the DBA views.
-- Call Syntax  : @dg_arch_destination
-- Last Modified: 31/07/2014
-- -----------------------------------------------------------------------------------
COLUMN destination FORMAT A35 WRAP 
column process format a7 
column archiver format a8 
column ID format 99 
 
select dest_id "ID",destination,status,target, 
archiver,schedule,process,mountid  
from v$archive_dest; 
 