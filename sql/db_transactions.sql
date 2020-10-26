-- -----------------------------------------------------------------------------------
-- File Name    : db_transactions.sql
-- Description  : Show information about database transactions
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_transactions.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT a.sid, a.username, b.name, b.xidusn, b.used_urec, b.used_ublk
  FROM v$session a, v$transaction b
  WHERE a.saddr = b.ses_addr;
