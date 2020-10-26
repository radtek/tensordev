-- -----------------------------------------------------------------------------------
-- File Name    : asm_disks_status_01.sql
-- Description  : Verifying ASM Disks
-- Requirements : Access to the DBA views.
-- Call Syntax  : @asm_disks_status_01.sql
-- Last Modified: 09/04/2012
-- -----------------------------------------------------------------------------------
prompt
prompt
prompt Type the Disk Group name to list specific disks or type ALL to list all disks in the ASM
prompt
prompt

undefine name

set line 200 pages 5000 colsep |

col    "Group"            format 999
col    "DG Name"          format a16
col    "Disk"             format 999
col    "Header"           format a9
col    "Mode"             format a8
col    "Redundancy"       format a10
col    "Disk Name"        format a20
col    "Failure Group"    format a20
col    "Path"             format a30

SELECT a.group_number "Group", 
       b.name as "DG Name", 
	   a.disk_number "Disk", 
	   a.header_status "Header", 
	   a.mode_status "Mode", 
	   a.state "State", 
	   a.redundancy "Redundancy", 
	   a.total_mb "Total MB", 
	   a.free_mb "Free MB", 
	   decode(a.total_mb,0,0,(ROUND((1- (a.free_mb / a.total_mb))*100, 2))) as "% Used", 
	   a.name "Disk Name", 
	   a.failgroup "Failure Group", 
	   a.path "Path"
FROM v$asm_disk a, v$asm_diskgroup b
WHERE a.group_number = b.group_number
    AND b.name = DECODE('&&name', 'ALL', b.name, '&name')
ORDER BY a.group_number, a.disk_number
/
