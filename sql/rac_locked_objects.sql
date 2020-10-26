-- -----------------------------------------------------------------------------------
-- File Name    : rac_locked_objects.sql
-- Description  : Displays locked objects for the whole rac
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rac_locked_objects.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

COLUMN OWNER FORMAT A20
COLUMN USERNAME FORMAT A20
COLUMN OBJECT_OWNER FORMAT A20
COLUMN OBJECT_NAME FORMAT A30
COLUMN LOCKED_MODE FORMAT A15

SELECT B.INST_ID,
       B.SESSION_ID AS SID,
       NVL(B.ORACLE_USERNAME, '(oracle)') AS USERNAME,
       A.OWNER AS OBJECT_OWNER,
       A.OBJECT_NAME,
       DECODE(B.LOCKED_MODE, 0, 'None',
                             1, 'Null (NULL)',
                             2, 'Row-S (SS)',
                             3, 'Row-X (SX)',
                             4, 'Share (S)',
                             5, 'S/Row-X (SSX)',
                             6, 'Exclusive (X)',
                             B.LOCKED_MODE) LOCKED_MODE,
       B.OS_USER_NAME
FROM   DBA_OBJECTS A,
       GV$LOCKED_OBJECT B
WHERE  A.OBJECT_ID = B.OBJECT_ID
ORDER BY 1, 2, 3, 4;

SET PAGESIZE 14
SET VERIFY ON
