-- -----------------------------------------------------------------------------------
-- File Name    : db_kill_inactive_session.sql
-- Description  : Este script serve para matar as sessões que estão sem uso por mais de 
--                3 horas no banco de dados e estejam com o status SNIPED ou INACTIVE. 
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_kill_inactive_session.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
BEGIN FOR matarSessoesSniped IN (select 'alter system kill session '''||sid||','||serial#||'''' AS matarSessao
                                 from v$session 
								 where status in ('SNIPED','INACTIVE') 
								   AND seconds_in_wait > 10800 
								   AND Upper(username) = '&&username' LOOP

      EXECUTE IMMEDIATE matarSessoesSniped.matarSessao;

  END LOOP;
END;
/
