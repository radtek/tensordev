-- -----------------------------------------------------------------------------------
-- File Name    : rac_session_undo.sql
-- Description  : Displays undo information on relevant database sessions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @rac_session_undo
-- Last Modified: 02/10/2018
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

COLUMN USERNAME FORMAT A15

SELECT S.INST_ID,
       S.USERNAME,
       S.SID,
       S.SERIAL#,
       T.USED_UBLK,
       T.USED_UREC,
       RS.SEGMENT_NAME,
       R.RSSIZE,
       R.STATUS
FROM GV$TRANSACTION T,
     GV$SESSION S,
     GV$ROLLSTAT R,
     DBA_ROLLBACK_SEGS RS
WHERE S.SADDR = T.SES_ADDR
  AND S.INST_ID = T.INST_ID
  AND T.XIDUSN = R.USN
  AND T.INST_ID = R.INST_ID
  AND RS.SEGMENT_ID = T.XIDUSN
ORDER BY T.USED_UBLK DESC;
