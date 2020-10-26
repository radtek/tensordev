-- -----------------------------------------------------------------------------------
-- File Name    : query_ldapprd.sql
-- Description  : Lista o inventário de bases do Database Office NET
-- Requirements : Access to the DBA views.
-- Call Syntax  : @query_ldapprd.sql
-- Last Modified: 30/06/2014
-- -----------------------------------------------------------------------------------
SET LINES 180

COL INSTANCE_NAME FORMAT a10
COL HOST_NAME     FORMAT a20
COL DESCRIPTION   FORMAT a20

SELECT    INSTANCE_NAME
        , DB_NAME
        , DB_VERSION
        , RAC_DB
        , USE_ASM
        , LAST_CPU
        , INSTANCE_NUMBER AS INST_NM
        , PORT
        , HOST_NAME
        , HOST_IP
        , SUBSTR(OPERATIONAL_SYSTEM,1,10)
        , BITS
        , SUBSTR(DESCRIPTION,1,20)
        , BUSINESS_LINE
FROM NETDBA.TAB_DBINVENTORY
#WHERE INSTANCE_NAME LIKE '%CAT%'
ORDER BY INSTANCE_NAME
/
