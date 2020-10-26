-- -----------------------------------------------------------------------------------
-- File Name    : asm_usage.sql
-- Description  : Verifying ASM usage
-- Requirements : Access to the DBA views.
-- Call Syntax  : @asm_usage.sql
-- Last Modified: 09/04/2014
-- -----------------------------------------------------------------------------------
prompt
prompt
prompt Type the Diskgroup Name or type ALL to list all the Disk Groups in the ASM
prompt
prompt

UNDEFINE NAME

SET LINES 200
SET PAGES 10000
SET COLSEP |

COL   "DG NUM"     FORMAT 999999
COL   "DG NAME"    FORMAT A20
COL   "STATE"      FORMAT A10
COL   "TOTAL GB"   FORMAT 999999999
COL   "FREE GB"    FORMAT 999999999
COL   "REDUNDANCY" FORMAT A10

SELECT GROUP_NUMBER AS "DG NUM", 
       NAME AS "DG NAME", 
	   STATE AS "STATE", 
	   ROUND(TOTAL_MB/1024) AS "TOTAL GB", 
	   ROUND(TOTAL_MB/1024-FREE_MB/1024) AS "USED GB", 
	   ROUND(FREE_MB/1024) AS "FREE GB",
       ROUND((1- (FREE_MB / TOTAL_MB))*100,1) AS "% USED",
       TYPE AS "REDUNDANCY"
FROM V$ASM_DISKGROUP
WHERE NAME LIKE UPPER(DECODE('&&NAME', 'ALL', NAME, 'ALL', NAME, '%&NAME%'))
ORDER BY NAME;
