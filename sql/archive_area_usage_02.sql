-- -----------------------------------------------------------------------------------
-- File Name    : archive_area_usage_02.sql
-- Description  : It checks what is consuming space in the Flash Recovery Area
-- Requirements : Access to the DBA views.
-- Call Syntax  : @archive_area_usage_02.sql
-- Last Modified: 27/05/2015
-- -----------------------------------------------------------------------------------

SET LINES 180
SET PAGES 1000
SET COLSEP |

SELECT * FROM V$RECOVERY_AREA_USAGE;
