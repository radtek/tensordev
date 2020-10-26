-- -----------------------------------------------------------------------------------
-- File Name    : rman_bkp_information_02.sql
-- Description  : Shows output log for the backup if OUT AVAILABLE in the query
--                rman_bkp_information is = 1
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rman_bkp_information_02.sql
-- Last Modified: 18/07/2014
-- -----------------------------------------------------------------------------------

SET LINES 200 PAGES 10000 COLSEP |

SELECT OUTPUT
FROM GV$RMAN_OUTPUT
WHERE SESSION_RECID = &SESSION_RECID
  AND SESSION_STAMP = &SESSION_STAMP
ORDER BY RECID;
