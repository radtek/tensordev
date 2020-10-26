-- -----------------------------------------------------------------------------------
-- File Name    : db_size_by_owner.sql
-- Description  : Shows database size by owner
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_size_by_owner.sql
-- Last Modified: 03/04/2012
-- -----------------------------------------------------------------------------------

COL       owner               format a20
COL       GBytes              format 9999999999
COL       tablespace_name     format a20

PROMPT 
PROMPT Esta query verifica o tamanho de cada schema (Nao Oracle) em GB na base de dados
PROMPT 

select owner, tablespace_name, round(sum(bytes)/1024/1024/1024,2) as "GBYTES" 
from DBA_SEGMENTS
where owner  NOT IN (
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
group by owner, tablespace_name
order by 3 desc;
