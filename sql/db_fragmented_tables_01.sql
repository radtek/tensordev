-- -----------------------------------------------------------------------------------
-- File Name    : db_fragmented_tables_01.sql
-- Description  : This script lists details how chained or migrated rows there are 
--                within a table. It may help you determine if a table needs to be 
--                rebuilt. In order for this script to be effective, you must analyze 
--                your tables regularly
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_fragmented_tables_01.sql
-- Last Modified: 03/04/2012
-- -----------------------------------------------------------------------------------
CLEAR

SET HEAD ON
SET VERIFY OFF
SET PAGES 100
SET LINES 79

PROMPT 
PROMPT TABLE FRAGMENTATION REPORT
PROMPT

COL OWNER FORM A12
COL TABLE_NAME FORM A20
COL EMPTY_BLOCKS FORM 999,999 HEADING "EMPTY BLKS"
COL BLOCKS FORM 999,999 HEADING "BLKS"
COL PCT FORM 99

SELECT OWNER, TABLE_NAME, NUM_ROWS, CHAIN_CNT, (CHAIN_CNT*100/NUM_ROWS) PCT, EMPTY_BLOCKS, BLOCKS
FROM DBA_TABLES
WHERE CHAIN_CNT > 0
AND OWNER NOT IN ('SYS','SYSTEM')
/
