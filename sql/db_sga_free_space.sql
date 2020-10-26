-- -----------------------------------------------------------------------------------
-- File Name    : db_sga_free_space.sql
-- Description  : Reports free memory available in the SGA
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_sga_free_space.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select name,
       sgasize/1024/1024 "Allocated (M)",
       bytes/1024 "Free (K)",
       round(bytes/sgasize*100, 2) "% Free"
from   (select sum(bytes) sgasize from sys.v_$sgastat) s, sys.v_$sgastat f
where  f.name = 'free memory'
/
