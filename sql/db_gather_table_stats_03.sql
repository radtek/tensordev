-- -----------------------------------------------------------------------------------
-- File Name    : db_gather_table_stats_03.sql
-- Description  : This PL/SQL block gathers tables statistics according to the 
--                username specified
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_gather_table_stats_03.sql
-- Last Modified: 25/10/2017
-- -----------------------------------------------------------------------------------

PROMPT
PROMPT This PL/SQL block gathers tables statistics according to the owner specified.
PROMPT

DECLARE 

  OWNER       VARCHAR(250);
  TABLE_NAME  VARCHAR(250);

BEGIN
  FOR C IN
    (SELECT OWNER, TABLE_NAME FROM DBA_TABLES WHERE OWNER = '&OWNER')
  LOOP
    DBMS_STATS.GATHER_TABLE_STATS(C.OWNER, C.TABLE_NAME, DEGREE => 12, ESTIMATE_PERCENT => 100, CASCADE => TRUE, METHOD_OPT => 'for all indexed columns size auto');
  END LOOP;
END;
/
