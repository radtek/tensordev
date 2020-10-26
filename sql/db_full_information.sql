-- -----------------------------------------------------------------------------------
-- File Name    : db_full_information.sql
-- Description  : This script shows database full information
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_full_information.sql
-- Last Modified: 09/04/2014
-- -----------------------------------------------------------------------------------

set lines 180
set pages 10000

PROMPT
PROMPT This script will generate a log called db_full_infortion.log
PROMPT Attention: in the C:\ directory if it is run from SQL*Plus Client (Windows)
PROMPT .......... in the parent directory if it is run from  SQL*Plus Client (Unix / Linux)
PROMPT

set PAU OFF TIME ON HEADING ON FEEDBACK OFF TERMOUT OFF

spool db_full_infortion.log

prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Status                                                                                                          +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_up_information.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Version                                                                                                         +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_version.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Size                                                                                                            +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_size
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Size by Owner                                                                                                   +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_size_by_owner.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Controlfiles Information                                                                                        +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_controlfiles.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database SGA Information                                                                                                 +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_sga_information.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Tablespaces Status                                                                                                       +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@tbs_status.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Tablespaces Usage                                                                                                        +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@tbs_usage_01.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Datafiles Status                                                                                                         +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@df_usage.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Datafiles Usage                                                                                                          +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_datafile_usage.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + ASM Usage                                                                                                                +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@asm_usage.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + ASM Disks Status                                                                                                         +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@asm_disks_status.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Recovery Status                                                                                                 +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_recovery_status.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Redo Log Files Status                                                                                           +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_redo.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Registry Information                                                                                            +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_registry_information.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Registry History                                                                                                +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_registry_history.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Backup Information                                                                                              +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@ rman_bkp_information.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Corrupted Blocks                                                                                                +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_blocks_corrupted.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Invalid Indexes                                                                                                 +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_invalid_indexes.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Invalid Objects                                                                                                 +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_invalid_objects.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Objects Without Statistics                                                                                      +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_perf_objects_without_statistics.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt Database Resource Plans Information
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_resource_plans.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Jobs Information                                                                                                +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@job_status.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database I/O Information                                                                                                 +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_perf_file_io_efficiency.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Redo Log Contention Information                                                                                 +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_perf_redo_log_contention.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Top SQL by Disk Reads Information                                                                               +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_perf_top_sql_by_disk_reads.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Top SQL by Buffer Gets Information                                                                              +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_perf_top_sql_by_buffer_gets.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Database Hit Ratio By Session Information                                                                                +
prompt +--------------------------------------------------------------------------------------------------------------------------+
@db_perf_hit_ratio_by_session.sql
prompt
prompt
prompt +--------------------------------------------------------------------------------------------------------------------------+
prompt + Instance Parameters                                                                                                      +
prompt +--------------------------------------------------------------------------------------------------------------------------+
show parameters;

spool off;
exit;
