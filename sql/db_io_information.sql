-- -----------------------------------------------------------------------------------
-- File Name    : db_io_information.sql
-- Description  : Displays the amount of IO for each datafile
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_io_information.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET PAGESIZE 1000
SET LINES 200
COL name FOR a50
SELECT d.name,
       f.phyblkrd "Blocks Read",
       f.phyblkwrt "Blocks Writen",
       f.phyblkrd + f.phyblkwrt "Total I/O"
FROM   v$filestat f,
                v$datafile d
WHERE  d.file# = f.file#
ORDER BY f.phyblkrd + f.phyblkwrt DESC;
SET PAGESIZE 18
