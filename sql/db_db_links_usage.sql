-- -----------------------------------------------------------------------------------
-- File Name    : db_db_links_usage.sql
-- Description  : This script will show the user and session associated with using a 
--                database link at any given time 
-- Requirements : SYS connection.
-- Call Syntax  : @db_db_links_usage.sql
-- Last Modified: 25/10/2017
-- -----------------------------------------------------------------------------------

set lines 180
col osuser   format a10
col username format a10
col sid      format 99999
col module   format a30 truncate
col pai      format a10
col machine  format a10 truncate
col Logon    format a18
col origin   format a30
col gtxid    format a30
col lsession format a12 

SELECT /*+ ORDERED */
       SUBSTR(S.KSUSEMNM,1,20)||'-'|| SUBSTR(S.KSUSEPID,1,10) "ORIGIN",
       SUBSTR(G.K2GTITID_ORA,1,35) "GTXID",
       SUBSTR(S.INDX,1,4)||'.'|| SUBSTR(S.KSUSESER,1,5) "LSESSION" ,
       S2.USERNAME,
       DECODE(BITAND(KSUSEIDL,11),
              1,'ACTIVE',
              0, DECODE( BITAND(KSUSEFLG,4096) , 0,'INACTIVE','CACHED'),
              2,'SNIPED',
              3,'SNIPED',
              'KILLED') STATUS,
       S2.EVENT "WAITING"
FROM  X$K2GTE G, X$KTCXB T, X$KSUSE S, V$SESSION_WAIT W, V$SESSION S2
WHERE G.K2GTDXCB =T.KTCXBXBA
  AND G.K2GTDSES=T.KTCXBSES
  AND S.ADDR=G.K2GTDSES
  AND W.SID=S.INDX
  AND S2.SID = W.SID
/
