-- -----------------------------------------------------------------------------------
-- File Name    : db_character_set_info.sql
-- Description  : Database character set information
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_character_set_info.sql
-- Last Modified: 22/01/2013
-- -----------------------------------------------------------------------------------
col value format a40
select * from nls_database_parameters;
