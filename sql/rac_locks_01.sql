-- -----------------------------------------------------------------------------------
-- File Name    : rac_locks_01.sql
-- Description  : Verifying database locks in a RAC environment
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rac_locks_01.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT DECODE(request,0,'Holder: ','Waiter: ')||sid sess, 
   id1, id2, lmode, request, type 
   FROM GV$LOCK 
   WHERE (id1, id2, type) IN 
   (SELECT id1, id2, type FROM GV$LOCK WHERE request>0) 
   ORDER BY id1, request ;
