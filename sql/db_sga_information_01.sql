-- -----------------------------------------------------------------------------------
-- File Name    : db_sga_information_01.sql
-- Description  : Consultar redimensionamento da SGA, quando utiliza-se gerenciamento 
--                de memória automática
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_sga_information_01.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
col parameter for a40
col component for a30
select	  to_char(start_time,'hh24:mi:ss') timed_at,
          oper_type,
          component,
          parameter,
          oper_mode,
          initial_size/1024/1024 as "initial_size (mb)",
          final_size/1024/1024 as "final_size (mb)"
from	  v$sga_resize_ops
where	  start_time > trunc(sysdate)
order by  start_time, component; 
