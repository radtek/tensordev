-- -----------------------------------------------------------------------------------
-- File Name    : db_stmt_audit_opts.sql
-- Description  : Show Audited objects in the database
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_stmt_audit_opts.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 150 pages 250
select AUDIT_OPTION, SUCCESS, FAILURE from dba_stmt_audit_opts;
