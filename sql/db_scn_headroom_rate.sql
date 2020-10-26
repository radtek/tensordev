-- -----------------------------------------------------------------------------------
-- File Name    : db_scn_headromm_rate.sql
-- Description  : It checks the database SCN Headroom rate across the time
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_scn_headromm_rate.sql
-- Last Modified: 11/04/2019
-- -----------------------------------------------------------------------------------

set numwidth 17 
set pages 1000 

alter session set nls_date_format='DD/Mon/YYYY HH24:MI:SS'; 

SELECT tim, 
       gscn, 
	   round(rate), 
	   round((chk16kscn - gscn)/24/3600/16/1024,1) "Headroom" 
FROM (select tim, 
             gscn, 
		     rate, 
             (( 
             ((to_number(to_char(tim,'YYYY'))-1988)*12*31*24*60*60) + 
             ((to_number(to_char(tim,'MM'))-1)*31*24*60*60) + 
             (((to_number(to_char(tim,'DD'))-1))*24*60*60) + 
             (to_number(to_char(tim,'HH24'))*60*60) + 
             (to_number(to_char(tim,'MI'))*60) + 
             (to_number(to_char(tim,'SS'))) 
             ) * (16*1024)) chk16kscn 
      from (select FIRST_TIME tim, 
	               FIRST_CHANGE# gscn, 
                   ((NEXT_CHANGE#-FIRST_CHANGE#)/ 
                   ((NEXT_TIME-FIRST_TIME)*24*60*60)) rate 
            from v$archived_log 
            where (next_time > first_time) 
           ) 
     ) 
order by 1,2; 
