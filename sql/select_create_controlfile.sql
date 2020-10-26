-- -----------------------------------------------------------------------------------
-- File Name    : select_create_controlfile.sql
-- Description  : Select para montar o create controlfile para quando o banco está em 
--                mount, utilizando somente as V$
-- Requirements : Access to the DBA views.
-- Call Syntax  : @select_create_controlfile.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select 'CREATE CONTROLFILE SET DATABASE "' || T.VALUE || '" RESETLOGS NOARCHIVELOG' as X
from V$PARAMETER T
where T.NAME = 'db_name'
union all
select ' MAXLOGFILES ' || T.RECORDS_TOTAL
from V$CONTROLFILE_RECORD_SECTION T
where T.TYPE = 'REDO LOG'
union all
select ' MAXLOGMEMBERS ' || DIMLM
from SYS.X$KCCDI
union all
select ' MAXDATAFILES ' || T.RECORDS_TOTAL
from V$CONTROLFILE_RECORD_SECTION T
where T.TYPE = 'DATAFILE'
union all
select ' MAXINSTANCES ' || T.RECORDS_TOTAL
from V$CONTROLFILE_RECORD_SECTION T
where T.TYPE = 'DATABASE'
union all
select ' MAXLOGHISTORY ' || T.RECORDS_TOTAL
from V$CONTROLFILE_RECORD_SECTION T
where T.TYPE = 'LOG HISTORY'
union all
select 'LOGFILE' as X
from DUAL
union all
select ' GROUP ' || T.GROUP# || ' ' || '''' || T.MEMBER || ''' SIZE ' || TT.BYTES / 1024 / 1024 || 'M,'
from V$LOGFILE T, V$LOG TT
where T.GROUP# != 1
and T.GROUP# = TT.GROUP#
union all
select ' GROUP ' || T.GROUP# || ' ' || '''' || T.MEMBER || ''' SIZE ' || TT.BYTES / 1024 / 1024 || 'M'
from V$LOGFILE T, V$LOG TT
where T.GROUP# = 1
and TT.GROUP# = 1
union all
select 'DATAFILES' as X
from DUAL
union all
select ' ''' || T.NAME || ''',' as X
from V$DATAFILE T
where T.file# < (select max(TT.file#) from V$DATAFILE TT)
union all
select ' ''' || T.NAME || ''';' as X
from V$DATAFILE T
where T.file# = (select max(TT.file#) from V$DATAFILE TT);
