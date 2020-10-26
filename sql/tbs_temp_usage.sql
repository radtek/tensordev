-- -----------------------------------------------------------------------------------
-- File Name    : tbs_temp_usage.sql
-- Description  : Verificação completa de espaço em tablespaces teporárias.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tbs_temp_usage.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 120
SET PAGESIZE 1000
COLUMN file_name FORMAT a50
column tablespace_name for a30
SELECT T.TABLESPACE_NAME,
       SUM(BYTES / 1024 / 1024) TOTAL_MBYTES,
       SUM((F.BYTES - NVL(U.BLOCKS, 0) * T.BLOCK_SIZE) / 1024 / 1024) AVAIL_MBYTES
  FROM DBA_TABLESPACES T,
       DBA_TEMP_FILES F,
       (SELECT SUM(S.BLOCKS) BLOCKS, S.SEGRFNO#
          FROM V$TEMPSEG_USAGE S
         GROUP BY S.SEGRFNO#) U
 WHERE T.TABLESPACE_NAME = F.TABLESPACE_NAME
   AND F.FILE_ID = U.SEGRFNO#(+)
 GROUP BY T.TABLESPACE_NAME;

