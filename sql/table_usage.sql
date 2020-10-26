-- -----------------------------------------------------------------------------------
-- File Name    : table_usage.sql
-- Description  : Space used by the tables in the tablespaces (by tablespace)
-- Requirements : Access to the DBA views.
-- Call Syntax  : @table_usage.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINES 180
SET PAGES 10000

SELECT T.OWNER,
       T.TABLESPACE_NAME,
       T.TABLE_NAME,
       T.NUM_ROWS,
       SUM(S.BYTES) / 1024 / 1024 AS MBYTES,
       T.COMPRESS_FOR
  FROM DBA_TABLES T, DBA_SEGMENTS S
 WHERE T.OWNER = S.OWNER
   AND T.TABLE_NAME = S.SEGMENT_NAME
   AND T.OWNER NOT IN ('ANONYMOUS',
                       'APEX_PUBLIC_USER',
                       'APEX_030200',
                       'APPQOSSYS',
                       'CTXSYS',
                       'DBSNMP',
                       'DIP',
                       'EXFSYS',
                       'FLOWS_FILES',
                       'MDDATA',
                       'MDSYS',
                       'MGMT_VIEW',
                       'OLAPSYS',
                       'ORACLE_OCM',
                       'ORDDATA',
                       'ORDPLUGINS',
                       'ORDSYS',
                       'OUTLN',
                       'OWBSYS',
                       'OWBSYS_AUDIT',
                       'SCOTT',
                       'SI_INFORMTN_SCHEMA',
                       'SPATIAL_CSW_ADMIN_USR',
                       'SPATIAL_WFS_ADMIN_USR',
                       'SYS',
                       'SYSMAN',
                       'SYSTEM',
                       'WMSYS',
                       'XDB',
                       'XS$NULL')
 GROUP BY T.OWNER,
          T.TABLESPACE_NAME,
          T.TABLE_NAME,
          T.NUM_ROWS,
          T.COMPRESS_FOR
 ORDER BY T.OWNER, T.TABLESPACE_NAME, T.TABLE_NAME

/
