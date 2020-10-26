-- -----------------------------------------------------------------------------------
-- File Name    : user_complete_info.sql
-- Description  : Display better information about user creation in the database with 
--                last logon.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @user_complete_info.sql
-- Last Modified: 03/04/2014
-- -----------------------------------------------------------------------------------
SET lines 180
SET pages 10000
SET colsep |

COL    "Usuario"       FORMAT  a16
COL    "Status"        FORMAT  a20
COL    "Perfil"        FORMAT  a20
col    "Criado em"     FORMAT  a20
col    "Ultimo Logon"  FORMAT  a20

PROMPT
PROMPT AS INFORMACOES DE ULTIMO LOGON SOMENTE SAO POSSIVEIS SE O DATABASE ESTIVER COM AUDIT_TRAIL = DB
PROMPT


SELECT a.username AS "Usuario", 
	   SUBSTR(a.account_status,1,16) AS "Status",
	   a.profile AS "Perfil",
       TO_CHAR(a.created, 'dd/mm/yyyy HH24:MI') AS "Criado em", 
	   TO_CHAR(b.timestamp, 'dd/mm/yyyy HH24:MI') AS "Ultimo Logon", 
	   DECODE(c.ptime, NULL, 'Autenticacao Externa', TO_CHAR(c.ptime, 'dd/mm/yyyy HH24:MI')) AS "Ultima Senha em"
FROM dba_users a, sys.user$ c LEFT OUTER JOIN 
                             (SELECT username, MAX(timestamp) AS timestamp FROM dba_audit_session WHERE action_name = 'LOGON' GROUP BY username) b 
							  ON (c.name = b.username)
WHERE a.username = c.name 
  AND a.username NOT IN  (
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
						  'SCOTT',
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
ORDER BY b.timestamp DESC
/
