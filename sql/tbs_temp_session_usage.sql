-- -----------------------------------------------------------------------------------
-- File Name    : tbs_temp_session_usage.sql
-- Description  : Sessões no banco que estão consumindo tablespace temporária
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tbs_temp_session_usage.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT t1.inst_id, t1.username, t1.sql_id, t1.TABLESPACE, t1.segtype,
         t2.SID, t1.session_num AS serial#,
         SUM (t1.blocks * 8192 / 1024 / 1024) AS size_mb_temp
    FROM gv$tempseg_usage t1, gv$session t2
   WHERE t1.session_num = t2.serial#
     AND t2.saddr = t1.session_addr
     AND t1.inst_id = t2.inst_id
GROUP BY t1.inst_id, t1.username, t1.sql_id,
        t1.TABLESPACE, t1.segtype, t2.SID, t1.session_num
ORDER BY size_mb_temp DESC;
