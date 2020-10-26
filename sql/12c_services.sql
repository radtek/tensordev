-- -----------------------------------------------------------------------------------
-- File Name    : 12c_services.sql
-- Description  : Displays information about database services.
-- Requirements : Access to the DBA views.
-- Call Syntax  : 12c_services
-- Last Modified: 02/08/2018
-- -----------------------------------------------------------------------------------

SET LINESIZE 200 PAGES 5000 COLSEP |

COLUMN name FORMAT A30
COLUMN network_name FORMAT A50
COLUMN pdb FORMAT A20

SELECT NAME,
       NETWORK_NAME,
       PDB
FROM   DBA_SERVICES
ORDER BY NAME;
