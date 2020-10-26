-- -----------------------------------------------------------------------------------
-- File Name    : db_objects_01.sql
-- Description  : Show the ten largest objects in the database
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_objects_01.sql
-- Last Modified: 22/01/2013
-- -----------------------------------------------------------------------------------
col	owner format a15
col	segment_name format a30
col	segment_type format a15
col	mb format 999,999,999
select  owner
,	segment_name
,	segment_type
,	mb
from	(
	select	owner
	,	segment_name
	,	segment_type
	,	bytes / 1024 / 1024 "MB"
	from	dba_segments
	order	by bytes desc
	)
where	rownum < 11
/
