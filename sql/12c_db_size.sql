-- -----------------------------------------------------------------------------------
-- File Name    : 12c_db_size.sql
-- Description  : Database sizes (For Oracle Database 12c). Used and allocated. It
--                must be run as SYSDBA
-- Requirements : Access to the DBA views.
-- Call Syntax  : @12c_db_size.sql
-- Last Modified: 18/02/2016
-- -----------------------------------------------------------------------------------

COL PDB_CDB_NAME FORMAT A20

SELECT USED.PDB_CDB_NAME,
       ROUND(SUM(USED.BYTES)/1024/1024/1024,2) ALLOCATE_SIZE_GB,
       ROUND(SEG.BYTES/1024/1024/1024,2) REAL_USED_GB,
	   ROUND(SUM(USED.BYTES)/1024/1024/1024,2) - ROUND(SEG.BYTES/1024/1024/1024,2) FREE_SPACE_GB,
	   ROUND((1- (((ROUND(SUM(USED.BYTES)/1024/1024/1024,2) - ROUND(SEG.BYTES/1024/1024/1024,2)) / ROUND(SUM(USED.BYTES)/1024/1024/1024,2))))*100, 1) AS "% USED"
FROM (SELECT NVL(A.PDB_NAME, 'CDB$ROOT') PDB_CDB_NAME, B.BYTES 
      FROM CDB_PDBS A RIGHT JOIN CDB_DATA_FILES B ON (A.CON_ID = B.CON_ID)
	  UNION ALL
      SELECT NVL(A.PDB_NAME, 'CDB$ROOT') PDB_CDB_NAME, B.BYTES 
	  FROM CDB_PDBS A RIGHT JOIN CDB_TEMP_FILES B ON (A.CON_ID = B.CON_ID)) USED,
	 (SELECT NVL(A.PDB_NAME, 'CDB$ROOT') PDB_CDB_NAME, SUM(B.BYTES) BYTES 
	  FROM CDB_PDBS A RIGHT JOIN CDB_SEGMENTS B ON (A.CON_ID = B.CON_ID) 
	  GROUP BY NVL(A.PDB_NAME, 'CDB$ROOT')) SEG
WHERE USED.PDB_CDB_NAME = SEG.PDB_CDB_NAME
GROUP BY USED.PDB_CDB_NAME, SEG.BYTES
ORDER BY USED.PDB_CDB_NAME
/
