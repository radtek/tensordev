-- -----------------------------------------------------------------------------------
-- File Name    : rman_backup_pieces.sql
-- Description  : Provide a listing of all RMAN Backup Pieces
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rman_backup_pieces.sql
-- Last Modified: 19/08/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 180
SET PAGESIZE 5000

COLUMN bs_key              FORMAT 99999         HEADING 'BS Key'
COLUMN piece#              FORMAT 999999        HEADING 'Piece'
COLUMN copy#               FORMAT 9999          HEADING 'Copy'
COLUMN bp_key              FORMAT 99999         HEADING 'BP Key'
COLUMN status              FORMAT a10           HEADING 'Status'
COLUMN handle              FORMAT a43           HEADING 'Piece Handle'
COLUMN media               FORMAT a06           HEADING 'Media'
COLUMN start_time          FORMAT a17           HEADING 'Start Time'
COLUMN completion_time     FORMAT a17           HEADING 'End Time'
COLUMN elapsed_seconds     FORMAT 999,999       HEADING 'Seconds'
COLUMN deleted             FORMAT a8            HEADING 'Deleted?'

BREAK ON bs_key

prompt
prompt Available backup pieces contained in the control file.
prompt Includes available and expired backup sets.
prompt 

SELECT
    bs.recid                                            bs_key
  , bp.piece#                                           piece#
  , bp.copy#                                            copy#
  , bp.recid                                            bp_key
  , DECODE(   status
            , 'A', 'Available'
            , 'D', 'Deleted'
            , 'X', 'Expired')                           status
  , handle                                              handle
  , bp.media											media
  , TO_CHAR(bp.start_time, 'dd/mm/yy HH24:MI:SS')       start_time
  , TO_CHAR(bp.completion_time, 'mm/dd/yy HH24:MI:SS')  completion_time
  , bp.elapsed_seconds                                  elapsed_seconds
FROM
    v$backup_set    bs
  , v$backup_piece  bp
WHERE
      bs.set_stamp = bp.set_stamp
  AND bs.set_count = bp.set_count
  AND bp.status IN ('A', 'X')
ORDER BY
    bs.recid
  , piece#
/

