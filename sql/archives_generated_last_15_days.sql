-- -----------------------------------------------------------------------------------
-- File Name    : archives_generated_last_15_days.sql
-- Description  : Script to check archive's generated per hour for last 15 days
-- Requirements : Access to the DBA views.
-- Call Syntax  : @archives_generated_last_15_days.sql
-- Last Modified: 14/12/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 180
SET PAGES 5000
SET COLSEP |
COL 00 FORMAT A4
COL 01 FORMAT A4
COL 02 FORMAT A4
COL 03 FORMAT A4
COL 04 FORMAT A4
COL 05 FORMAT A4
COL 06 FORMAT A4
COL 07 FORMAT A4
COL 08 FORMAT A4
COL 09 FORMAT A4
COL 10 FORMAT A4
COL 11 FORMAT A4
COL 12 FORMAT A4
COL 13 FORMAT A4
COL 14 FORMAT A4
COL 15 FORMAT A4
COL 16 FORMAT A4
COL 17 FORMAT A4
COL 18 FORMAT A4
COL 19 FORMAT A4
COL 20 FORMAT A4
COL 21 FORMAT A4
COL 22 FORMAT A4
COL 23 FORMAT A4
SELECT TO_DATE(FIRST_TIME) DAY,
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'00',1,0)),'999') "00",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'01',1,0)),'999') "01",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'02',1,0)),'999') "02",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'03',1,0)),'999') "03",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'04',1,0)),'999') "04",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'05',1,0)),'999') "05",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'06',1,0)),'999') "06",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'07',1,0)),'999') "07",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'08',1,0)),'999') "08",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'09',1,0)),'999') "09",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'10',1,0)),'999') "10",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'11',1,0)),'999') "11",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'12',1,0)),'999') "12",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'13',1,0)),'999') "13",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'14',1,0)),'999') "14",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'15',1,0)),'999') "15",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'16',1,0)),'999') "16",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'17',1,0)),'999') "17",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'18',1,0)),'999') "18",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'19',1,0)),'999') "19",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'20',1,0)),'999') "20",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'21',1,0)),'999') "21",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'22',1,0)),'999') "22", 
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'23',1,0)),'999') "23",
       COUNT (*) TOTAL,
	   ROUND((COUNT(*)/24),1) AS AVG
FROM V$LOG_HISTORY 
WHERE TO_DATE(FIRST_TIME) > SYSDATE -16
GROUP BY TO_CHAR(FIRST_TIME,'YYYY-MON-DD'), TO_DATE(FIRST_TIME)
ORDER BY TO_DATE(FIRST_TIME);
