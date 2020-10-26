-- -----------------------------------------------------------------------------------
-- File Name    : db_perf_objects_without_statistics.sql
-- Description  : Report on all objects that do not have statistics collected on them
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_perf_objects_without_statistics.sql
-- Last Modified: 10/04/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 145
SET PAGESIZE 9999
SET VERIFY   off

PROMPT
PROMPT This script shows information about objects that lack statistics collection
PROMPT Attention: For Non-Oracle standard users
PROMPT

COLUMN owner            FORMAT a17    HEAD 'Owner'
COLUMN object_type      FORMAT a15    HEAD 'Object Type'
COLUMN object_name      FORMAT a30    HEAD 'Object Name'
COLUMN partition_name   FORMAT a30    HEAD 'Partition Name'

SELECT
    owner           owner
  , 'Table'         object_type
  , table_name      object_name
  , NULL            partition_name
FROM
    sys.dba_tables 
WHERE
      last_analyzed IS NULL 
  AND owner NOT IN ('ANONYMOUS','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES','MDDATA','MDSYS','MGMT_VIEW','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS','OWBSYS_AUDIT','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','WMSYS','XDB','XS$NULL') 
  AND partitioned = 'NO' 
UNION 
SELECT
    owner           owner
  , 'Index'         object_type
  , index_name      object_name
  , NULL            partition_name
FROM
    sys.dba_indexes 
WHERE
      last_analyzed IS NULL 
  AND owner NOT IN ('ANONYMOUS','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES','MDDATA','MDSYS','MGMT_VIEW','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS','OWBSYS_AUDIT','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','WMSYS','XDB','XS$NULL') 
  AND partitioned = 'NO' 
UNION 
SELECT
    table_owner       owner
  , 'Table Partition' object_type
  , table_name        object_name
  , partition_name    partition_name
FROM
    sys.dba_tab_partitions 
WHERE
      last_analyzed IS NULL 
  AND table_owner NOT IN ('ANONYMOUS','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES','MDDATA','MDSYS','MGMT_VIEW','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS','OWBSYS_AUDIT','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','WMSYS','XDB','XS$NULL') 
UNION 
SELECT
    index_owner       owner
  , 'Index Partition' object_type
  , index_name        object_name
  , partition_name    partition_name
FROM
    sys.dba_ind_partitions 
WHERE
      last_analyzed IS NULL 
  AND index_owner NOT IN ('ANONYMOUS','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES','MDDATA','MDSYS','MGMT_VIEW','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS','OWBSYS_AUDIT','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','WMSYS','XDB','XS$NULL')
ORDER BY
    1
  , 2
  , 3
/
