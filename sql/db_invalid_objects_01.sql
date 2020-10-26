-- -----------------------------------------------------------------------------------
-- File Name    : db_invalid_objects_01.sql
-- Description  : Displays Database invalid objects (Owners Not Oracle)
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_invalid_objects_01.sql
-- Last Modified: 15/02/2016
-- -----------------------------------------------------------------------------------

set lines 180
set pages 10000
col owner format a20
col object_name for a40
select owner, object_type, status, count(*) as TOTAL
from dba_objects
where status = 'INVALID'
  and owner  NOT IN (
                     'ANONYMOUS',
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
                     'SI_INFORMTN_SCHEMA',
                     'SPATIAL_CSW_ADMIN_USR',
                     'SPATIAL_WFS_ADMIN_USR',
                     'SYS',
                     'SYSMAN',
                     'SYSTEM',
                     'WMSYS',
                     'XDB',
                     'XS$NULL'
                    )
group by owner, object_type, status
order by owner, object_type;
