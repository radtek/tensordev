-- -----------------------------------------------------------------------------------
-- File Name    : tbs_estimated_growth_01.sql
-- Description  : This script shows the growth analysis of a specific tablespace in the
--                database
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tbs_estimated_growth_01
-- Last Modified: 15/10/2018
-- -----------------------------------------------------------------------------------

set serverout on
set verify off
set lines 200
set pages 2000
DECLARE
v_ts_id number;
not_in_awr EXCEPTION;
v_ts_name varchar2(200) := UPPER('&Tablespace_Name');
v_ts_block_size number;
v_begin_snap_id number;
v_end_snap_id number;
v_begin_snap_date date;
v_end_snap_date date;
v_numdays number;
v_ts_begin_size number;
v_ts_end_size number;
v_ts_growth number;
v_count number;
v_ts_begin_allocated_space number;
v_ts_end_allocated_space number;
BEGIN
SELECT ts# into v_ts_id FROM v$tablespace where name = v_ts_name;
SELECT count(*) INTO v_count FROM dba_hist_tbspc_space_usage where tablespace_id=v_ts_id;
IF v_count = 0 THEN 
RAISE not_in_awr;
END IF ;
		SELECT block_size into v_ts_block_size 
		  FROM dba_tablespaces 
		  where tablespace_name = v_ts_name;
		SELECT min(snap_id), max(snap_id), min(trunc(to_date(rtime,'MM/DD/YYYY HH24:MI:SS'))), max(trunc(to_date(rtime,'MM/DD/YYYY HH24:MI:SS')))
		  into v_begin_snap_id,v_end_snap_id, v_begin_snap_date, v_end_snap_date 
		  from dba_hist_tbspc_space_usage 
		 where tablespace_id=v_ts_id;
     v_numdays := v_end_snap_date - v_begin_snap_date;
SELECT round(max(tablespace_size)*v_ts_block_size/1024/1024,2) into v_ts_begin_allocated_space from dba_hist_tbspc_space_usage where tablespace_id=v_ts_id and snap_id = v_begin_snap_id;
SELECT round(max(tablespace_size)*v_ts_block_size/1024/1024,2) into v_ts_end_allocated_space from dba_hist_tbspc_space_usage where tablespace_id=v_ts_id and snap_id = v_end_snap_id;
SELECT round(max(tablespace_usedsize)*v_ts_block_size/1024/1024,2) into v_ts_begin_size from dba_hist_tbspc_space_usage where tablespace_id=v_ts_id and snap_id = v_begin_snap_id;
SELECT round(max(tablespace_usedsize)*v_ts_block_size/1024/1024,2) into v_ts_end_size from dba_hist_tbspc_space_usage where tablespace_id=v_ts_id and snap_id = v_end_snap_id;
v_ts_growth := v_ts_end_size - v_ts_begin_size;
			DBMS_OUTPUT.PUT_LINE(CHR(10));
			DBMS_OUTPUT.PUT_LINE('Tablespace Block Size: '||v_ts_block_size);
			DBMS_OUTPUT.PUT_LINE('---------------------------');
			DBMS_OUTPUT.PUT_LINE(CHR(10));
			DBMS_OUTPUT.PUT_LINE('Summary');
			DBMS_OUTPUT.PUT_LINE('========');
			DBMS_OUTPUT.PUT_LINE('1) Allocated Space: '||v_ts_end_allocated_space||' MB'||' ('||round(v_ts_end_allocated_space/1024,2)||' GB)');
			DBMS_OUTPUT.PUT_LINE('2) Used Space: '||v_ts_end_size||' MB'||' ('||round(v_ts_end_size/1024,2)||' GB)');
			DBMS_OUTPUT.PUT_LINE('3) Used Space Percentage: '||round(v_ts_end_size/v_ts_end_allocated_space*100,2)||' %');
			DBMS_OUTPUT.PUT_LINE(CHR(10));
			DBMS_OUTPUT.PUT_LINE('History');
			DBMS_OUTPUT.PUT_LINE('========');
			DBMS_OUTPUT.PUT_LINE('1) Allocated Space on '||v_begin_snap_date||': '||v_ts_begin_allocated_space||' MB'||' ('||round(v_ts_begin_allocated_space/1024,2)||' GB)');
			DBMS_OUTPUT.PUT_LINE('2) Current Allocated Space on '||v_end_snap_date||': '||v_ts_end_allocated_space||' MB'||' ('||round(v_ts_end_allocated_space/1024,2)||' GB)');
			DBMS_OUTPUT.PUT_LINE('3) Used Space on '||v_begin_snap_date||': '||v_ts_begin_size||' MB'||' ('||round(v_ts_begin_size/1024,2)||' GB)' );
			DBMS_OUTPUT.PUT_LINE('4) Current Used Space on '||v_end_snap_date||': '||v_ts_end_size||' MB'||' ('||round(v_ts_end_size/1024,2)||' GB)' );
			DBMS_OUTPUT.PUT_LINE('5) Total growth during last '||v_numdays||' days between '||v_begin_snap_date||' and '||v_end_snap_date||': '||v_ts_growth||' MB'||' ('||round(v_ts_growth/1024,2)||' GB)');
    IF (v_ts_growth <= 0 OR v_numdays <= 0) THEN
				DBMS_OUTPUT.PUT_LINE(CHR(10));
				DBMS_OUTPUT.PUT_LINE('!!! NO DATA GROWTH WAS FOUND FOR TABLESPCE '||V_TS_NAME||' !!!');
    ELSE
	           DBMS_OUTPUT.PUT_LINE('6) Per day growth during last '||v_numdays||' days: '||round(v_ts_growth/v_numdays,2)||' MB'||' ('||round((v_ts_growth/v_numdays)/1024,2)||' GB)');
	           DBMS_OUTPUT.PUT_LINE(CHR(10));
	           DBMS_OUTPUT.PUT_LINE('Expected Growth');
	           DBMS_OUTPUT.PUT_LINE('===============');
	           DBMS_OUTPUT.PUT_LINE('1) Expected growth for next 30 days: '|| round((v_ts_growth/v_numdays)*30,2)||' MB'||' ('||round(((v_ts_growth/v_numdays)*30)/1024,2)||' GB)');
	           DBMS_OUTPUT.PUT_LINE('2) Expected growth for next 60 days: '|| round((v_ts_growth/v_numdays)*60,2)||' MB'||' ('||round(((v_ts_growth/v_numdays)*60)/1024,2)||' GB)');
	           DBMS_OUTPUT.PUT_LINE('3) Expected growth for next 90 days: '|| round((v_ts_growth/v_numdays)*90,2)||' MB'||' ('||round(((v_ts_growth/v_numdays)*90)/1024,2)||' GB)');
    END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE(CHR(10));
DBMS_OUTPUT.PUT_LINE('!!! TABLESPACE DOES NOT EXIST !!!');
WHEN NOT_IN_AWR THEN
DBMS_OUTPUT.PUT_LINE(CHR(10));
DBMS_OUTPUT.PUT_LINE('!!! TABLESPACE USAGE INFORMATION NOT FOUND IN AWR !!!');

END;
/
