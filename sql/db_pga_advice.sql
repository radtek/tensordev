-- -----------------------------------------------------------------------------------
-- File Name    : db_pga_advice.sql
-- Description  : Script to check PGA advices
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_pga_advice.sql
-- Last Modified: 07/04/2015
-- -----------------------------------------------------------------------------------
set lines 180
set pages 10000

select pga_target_for_estimate, pga_target_factor, estd_extra_bytes_rw 
from v$pga_target_advice;
