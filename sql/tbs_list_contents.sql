-- -----------------------------------------------------------------------------------
-- File Name    : tbs_list_contents.sql
-- Description  : Displays all the objects for a specific tablespace.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tbs_list_contents.sql
-- Last Modified: 05/02/2015
-- -----------------------------------------------------------------------------------

select owner, segment_type, segment_name, tablespace_name 
from dba_segments 
where tablespace_name = '&tablespace' 
order by owner, segment_type
/
