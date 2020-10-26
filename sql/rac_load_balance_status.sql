-- -----------------------------------------------------------------------------------
-- File Name    : rac_load_balance_status.sql
-- Description  : Verificar balanceamento das instâncias em Oracle RAC
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rac_load_balance_status.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select count(*),inst_id from gv$session group by inst_id;
