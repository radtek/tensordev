-- -----------------------------------------------------------------------------------
-- File Name    : db_used_features.sql
-- Description  : Show all database used features
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_used_features.sql
-- Last Modified: 22/01/2013
-- -----------------------------------------------------------------------------------
col name format a60
select	name, detected_usages
from	dba_feature_usage_statistics
where 	detected_usages > 0
/
