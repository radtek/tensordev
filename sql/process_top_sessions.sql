-- -----------------------------------------------------------------------------------
-- File Name    : process_top_sessions.sql
-- Description  : Verifica as top sessions no banco de dados (WHERE OSUSER <> "oracle")
-- Requirements : Access to the DBA views.
-- Call Syntax  : @process_top_sessions.sql
-- Last Modified: 03/09/2015
-- -----------------------------------------------------------------------------------
COL USERNAME FOR A20
COL OSUSER FOR A12
COL EVENT FOR A40
COL PROGRAM FOR A20
COL MACHINE FOR A18

SELECT T1.INST_ID, 
       T1.SID, 
	   T1.SQL_ID, 
	   T1.USERNAME, 
	   T1.OSUSER, 
	   T1.MACHINE, 
	   T1.PROGRAM, 
	   T1.EVENT, 
	   T1.SECONDS_IN_WAIT 
FROM (SELECT S.INST_ID, 
             S.SID, 
			 S.SQL_ID, 
			 S.USERNAME, 
			 S.OSUSER, 
			 S.MACHINE, 
			 S.PROGRAM, 
			 S.EVENT, 
			 S.SECONDS_IN_WAIT, 
			 ROW_NUMBER() OVER (PARTITION BY S.INST_ID ORDER BY S.SECONDS_IN_WAIT DESC) RNK
      FROM GV$SESSION S 
	  WHERE S.TYPE != 'BACKGROUND' 
	    AND S.SQL_ID IS NOT NULL 
		AND S.OSUSER != 'oracle'
     ) T1
WHERE T1.RNK <= 30
ORDER BY T1.SECONDS_IN_WAIT DESC, T1.INST_ID 
/
