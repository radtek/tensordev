-- -----------------------------------------------------------------------------------
-- File Name    : archive_area_usage_01.sql
-- Description  : It checks the space used in the Flash Recovery Area if the db is
--                using Archive Destination = USE_DB_RECOVERY_FILE_DEST
-- Requirements : Access to the DBA views.
-- Call Syntax  : @archive_area_usage_01.sql
-- Last Modified: 14/04/2015
-- -----------------------------------------------------------------------------------

SET LINES 180
SET PAGES 1000
SET COLSEP |

COL AREA FORMAT A20
SELECT NAME "AREA", 
       ROUND(SPACE_LIMIT/1024/1024/1024,2) "TOTAL SIZE GB", 
	   ROUND(SPACE_USED/1024/1024/1024,2) "SPACE USED GB", 
	   ROUND((SPACE_LIMIT/1024/1024/1024 - SPACE_USED/1024/1024/1024),2) "SPACE FREE GB", 
	   ROUND((SPACE_USED / 1048576) / (SPACE_LIMIT / 1048576),2)*100 "PERCENT USAGE %",
	   NUMBER_OF_FILES "NUMBER OF FILES"
FROM V$RECOVERY_FILE_DEST;
