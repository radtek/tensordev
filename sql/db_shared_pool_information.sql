-- -----------------------------------------------------------------------------------
-- File Name    : db_shared_pool_information.sql
-- Description  : Displays the consumption of shared pool
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_shared_pool_information.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT ROUND ((SHARED_POOL.BYTES - free.BYTES) / (1024 * 1024), 2) mb_used,
ROUND (SHARED_POOL.BYTES / (1024 * 1024), 2) size_in_mb,
ROUND (free.BYTES / (1024 * 1024), 2) mb_avail,
ROUND (((SHARED_POOL.BYTES - free.BYTES) / SHARED_POOL.BYTES) * 100,
2
) percent_used
FROM (SELECT current_size BYTES
FROM v$sga_dynamic_components
WHERE component = 'shared pool') SHARED_POOL,
(SELECT BYTES
FROM v$sgastat
WHERE pool = 'shared pool' AND NAME = 'free memory') free;
