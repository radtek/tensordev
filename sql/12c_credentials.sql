-- -----------------------------------------------------------------------------------
-- File Name    : 12c_credentials.sql
-- Description  : Displays information about credentials.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @12c_credentials
-- Last Modified: 02/10/2018
-- -----------------------------------------------------------------------------------
COL CREDENTIAL_NAME FORMAT A25
COL USERNAME FORMAT A20
COL WINDOWS_DOMAIN FORMAT A20

SELECT CREDENTIAL_NAME,
       USERNAME,
       WINDOWS_DOMAIN
FROM   DBA_CREDENTIALS
ORDER BY CREDENTIAL_NAME;
