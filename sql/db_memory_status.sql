-- -----------------------------------------------------------------------------------
-- File Name    : db_memory_status.sql
-- Description  : Verifying instance memory status. At the end this script generates a
--                lst file with the instance memory information
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_memory_status.sql
-- Last Modified: 03/04/2012
-- -----------------------------------------------------------------------------------
REM Starting script execution
CLE SCR
PROMPT .
PROMPT .              ======== SCRIPT TO MONITOR MEMORY USAGE BY DATABASE SESSIONS ========
PROMPT .

REM Setting environment variables
SET LINESIZE       200
SET PAGESIZE       500
SET FEEDBACK       OFF
SET VERIFY         OFF
SET SERVEROUTPUT   ON
SET TRIMSPOOL      ON
COL "SESSION"      FORMAT A50
COL "PID/THREAD"   FORMAT A10
COL "      CURRENT SIZE" FORMAT A18
COL "      MAXIMUM SIZE" FORMAT A18

REM Setting user variables values
SET    TERMOUT OFF
DEFINE sort_order = 3
DEFINE show_pga   = 'ON'
DEFINE show_uga   = 'ON'
COL    sort_column NEW_VALUE sort_order
COL    pga_column  NEW_VALUE show_pga
COL    uga_column  NEW_VALUE show_uga
COL    snap_column NEW_VALUE snap_time
SELECT nvl(:sort_choice, 3) "SORT_COLUMN"
FROM   dual
/
SELECT nvl(:pga_choice, 'ON') "PGA_COLUMN"
FROM   dual
/
SELECT nvl(:uga_choice, 'ON') "UGA_COLUMN"
FROM   dual
/
SELECT to_char(sysdate, 'YYYYMMDD_HH24MISS') "SNAP_COLUMN"
FROM   dual
/

REM Creating new snapshot spool file
SPOOL MEMORY_&snap_time

REM Showing PGA statistics for each session and background process
SET      TERMOUT &show_pga
PROMPT
PROMPT   :::::::::::::::::::::::::::::::::: PROGRAM GLOBAL AREA statistics :::::::::::::::::::::::::::::::::
SELECT   to_char(ssn.sid, '9999') || ' - ' || nvl(ssn.username, nvl(bgp.name, 'background')) ||
                  nvl(lower(ssn.machine), ins.host_name) "SESSION",
             to_char(prc.spid, '999999999') "PID/THREAD",
             to_char((se1.value/1024)/1024, '999G999G990D00') || ' MB' "      CURRENT SIZE",
             to_char((se2.value/1024)/1024, '999G999G990D00') || ' MB' "      MAXIMUM SIZE"
    FROM     v$sesstat se1, v$sesstat se2, v$session ssn, v$bgprocess bgp, v$process prc,
          v$instance ins,  v$statname stat1, v$statname stat2
 WHERE    se1.statistic# = stat1.statistic# and stat1.name = 'session pga memory'
 AND      se2.statistic#  = stat2.statistic# and stat2.name = 'session pga memory max'
 AND      se1.sid        = ssn.sid
 AND      se2.sid        = ssn.sid
 AND      ssn.paddr      = bgp.paddr (+)
 AND      ssn.paddr      = prc.addr  (+)
ORDER BY &sort_order DESC
/

REM Showing UGA statistics for each session and background process
SET      TERMOUT &show_uga
PROMPT
PROMPT   :::::::::::::::::::::::::::::::::::: USER GLOBAL AREA statistics ::::::::::::::::::::::::::::::::::
SELECT   to_char(ssn.sid, '9999') || ' - ' || nvl(ssn.username, nvl(bgp.name, 'background')) ||
                  nvl(lower(ssn.machine), ins.host_name) "SESSION",
             to_char(prc.spid, '999999999') "PID/THREAD",
             to_char((se1.value/1024)/1024, '999G999G990D00') || ' MB' "      CURRENT SIZE",
             to_char((se2.value/1024)/1024, '999G999G990D00') || ' MB' "      MAXIMUM SIZE"
    FROM     v$sesstat se1, v$sesstat se2, v$session ssn, v$bgprocess bgp, v$process prc,
          v$instance ins,  v$statname stat1, v$statname stat2
 WHERE    se1.statistic# = stat1.statistic# and stat1.name = 'session uga memory'
 AND      se2.statistic#  = stat2.statistic# and stat2.name = 'session uga memory max'
 AND      se1.sid        = ssn.sid
 AND      se2.sid        = ssn.sid
 AND      ssn.paddr      = bgp.paddr (+)
 AND      ssn.paddr      = prc.addr  (+)
ORDER BY &sort_order DESC
/

REM Showing sort information
SET TERMOUT ON
PROMPT
BEGIN
    IF (&sort_order = 1) THEN
        dbms_output.put_line('Ordered by SESSION');
    ELSIF (&sort_order = 2) THEN
        dbms_output.put_line('Ordered by PID/THREAD');
    ELSIF (&sort_order = 3) THEN
        dbms_output.put_line('Ordered by CURRENT SIZE');
    ELSIF (&sort_order = 4) THEN
        dbms_output.put_line('Ordered by MAXIMUM SIZE');
    END IF;
END;
/

REM Closing current snapshot spool file
SPOOL OFF

REM Showing the menu and getting sort order and information viewing choice
PROMPT
PROMPT Choose the column you want to sort:        == OR ==        You can choose which information to see:  
PROMPT ... 1. Order by SESSION                                    ... 5. PGA and UGA statistics (default)
PROMPT ... 2. Order by PID/THREAD                                 ... 6. PGA statistics only
PROMPT ... 3. Order by CURRENT SIZE (default)                     ... 7. UGA statistics only
PROMPT ... 4. Order by MAXIMUM SIZE
PROMPT
ACCEPT choice NUMBER PROMPT 'Enter the number of your choice or press <ENTER> to refresh information: '
VAR    sort_choice NUMBER
VAR    pga_choice  CHAR(3)
VAR    uga_choice  CHAR(3)
BEGIN
    IF (&choice = 1 OR &choice = 2 OR &choice = 3 OR &choice = 4) THEN
        :sort_choice := &choice;
        :pga_choice  := '&show_pga';
        :uga_choice  := '&show_uga';
    ELSIF (&choice = 5) THEN
        :sort_choice := &sort_order;
        :pga_choice  := 'ON';
        :uga_choice  := 'ON';
    ELSIF (&choice = 6) THEN
        :sort_choice := &sort_order;
        :pga_choice  := 'ON';
        :uga_choice  := 'OFF';
    ELSIF (&choice = 7) THEN
        :sort_choice := &sort_order;
        :pga_choice  := 'OFF';
        :uga_choice  := 'ON';
    ELSE
        :sort_choice := &sort_order;
        :pga_choice  := '&show_pga';
        :uga_choice  := '&show_uga';
    END IF;
END;
/

REM Finishing script execution
PROMPT Type "@db_memory_status" and press <ENTER>
SET FEEDBACK     ON
SET VERIFY       ON
SET SERVEROUTPUT OFF
SET TRIMSPOOL    OFF

REM =============
REM END OF SCRIPT
REM =============
