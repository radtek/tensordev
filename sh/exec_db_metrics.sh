#! /usr/bin/env bash
#conf_db_restorepoint.sh
#Objetivo: Criacao automatica de restore point em todos os bancos do servidor
# -> REVISOES
#    20/03/2020  -  Criacao                                                     -   jose.juliano@telefonica.com

##Verifica se WORKDIR está criado, senao sai do script
  if [ -d "/dbs/tools/" ]; then
    WORKDIR="/dbs/tools"
  elif [ -d "/oracle/admin" ]; then
    WORKDIR="/oracle/admin"
  else
    echo -e "\nERROR: Nao foi possivel detectar diretorio WORKDIR. Verifique se /dbs/tools ou /oracle/admin estao criados no servidor\n"
    exit 1
  fi
##VARs
BASENAME=$(basename $0 .sh)
GRID_HOME=$(ps -ef | grep d.bin | grep -v grep | grep ocssd.bin | awk {' print $8 '} | sed -n "s/bin\/\ocssd.bin//p")
OUTPUT_DIR=$WORKDIR/dbaops/output/$BASENAME
SH_DIR=$WORKDIR/dbaops/dbagit/sh
OUTPUT_FILE=cfgtbs
#CONFIG_DIR=/tmp/checagens/"$HOSTNAME"/settings.cfg
FULL_OS_VERSION=$(cat /etc/redhat-release)
OS_VERSION=$(cat /etc/redhat-release | awk {' print $7 '} | cut -d"." -f1)
RAC_FOUND=$(ps -ef | grep crsd.bin | grep -v grep | wc -l)
DTHR=$(date +"%Y%m%d%H%M")
FULL_OUTPUT_DIR=$OUTPUT_DIR/$OUTPUT_FILE.$DTHR
OGG_FOUND=$(ps -ef |grep ogg |egrep "replicat|extract" |wc -l)
secao_count=0
subsecao_count=0
sumariza_erro_count=0
sumariza_erro=0

fn_inicializa()
{
  #user_error=0
  #sai com erro se usuario nao for o dono do banco
  #for i in $(ps -ef | grep pmon | egrep -v "ASM|grep|APX|MGMTDB" | awk {' print $1 '} |sort -u); 
  #do
  #    if [ $USER = "$i" ]; then
  #      #let user_error++
  #      user_error=$((user_error+1))
  #    fi;
  #done;  
  #if [ "$user_error" = "0" ]; then
  #  echo -e "\nERROR: Somente o usuario dono da banco pode executar esse script\n"
  #  exit #1
  #fi;# 
  
  ##muda para diretorio sh
  cd $SH_DIR
  
  ##cria diretorio e/ou arquivos necessarios para execucao do script
  #VOLTAR
  if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
  fi
  
}

fn_output_influx ()
{
  ##Percorre todos os argumentos passados e gera linha unica com formato CSV
  for i in $(seq 1 $#); do
   eval "arg=\${$i}"
   if [ $i -eq $# ]; then
     local RESULTADO=$RESULTADO"$arg"
   else
     local RESULTADO=$RESULTADO"$arg,"
   fi
  done
  echo $RESULTADO #>> $FULL_OUTPUT_DIR.csv
  #unset RESULTADO
  #"metrics","brtlvlts0222fu","DIVERSOS","GIT","GIT","",""

}

fn_handle_error()
{
    echo -e "\nERROR: Erro inesperado. Codigo $1 - Linha $2\n"
    exit 1
}

fn_handle_ctrlc()
{
    echo -e "\nERROR: Interrompido pelo usuario. Codigo 2 - Linha $2\n"
    exit 2
}

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through time command and other functions
set -e           # terminate the script upon errors
#set -x          # debug mode

##CAPTURA SINAIS DE INTERRUPCAO
trap 'fn_handle_error $? $LINENO' ERR 1 3 9 15           #demais sinais de erro
trap 'fn_handle_ctrlc $? $LINENO' SIGINT SIGTSTP         #ctrlc ou ctrlz
trap 'rm .dbmetric_* 2>/dev/null' 0                          #limpa temp files qd terminado

fn_inicializa

for i in $(ps -ef | grep pmon | egrep -v "ASM|grep|APX|MGMTDB" | awk {' print substr($8,10) '}); do
ORACLE_SID=$i
ORAENV_ASK=NO
. oraenv 1>/dev/null <<EOF
$ORACLE_SID
EOF

##OBJ INVALIDOS
sqlplus -s / as sysdba <<EOF >.dbmetric_obj_$ORACLE_SID
set head off
set timi off
set time off
set lines 200
set echo off
set feedback off
select 
'status='||status||','||
'total='||count(*)
from dba_objects group by status;
EOF

for rowdb in $(cat .dbmetric_obj_$ORACLE_SID|grep "\S")
do  
  keytag=$(echo $rowdb |cut -d',' -f1)
  keyvalue=$(echo $rowdb |cut -d',' -f2-)
  echo "objetos,host="$HOSTNAME",db="$ORACLE_SID","$keytag" "$keyvalue
done;

##VERSAO DO BANCO
sqlplus -s / as sysdba <<EOF > .dbmetric_dbversion_$ORACLE_SID
set lines 200
set pages 500
set head off
set timi off
set time off
set echo off
set feedback off
select substr(banner,instr(banner,' ',1, 6)+1,10) from v\$version where rownum <2;
EOF

DB_VERSION=$(cat .dbmetric_dbversion_$ORACLE_SID|tr -d '\n')
##FIM VERSAO DO BANCO

# PATCH
if [ ${DB_VERSION%.*.*.*} == "12.1" ]; then
sqlplus -s / as sysdba <<EOF > .dbmetric_patch_$ORACLE_SID
set lines 200
set pages 500
set head off
set timi off
set time off
set echo off
set feedback off
select 
'patch='||replace(replace(replace(upper(description),' ','_'),'DATABASE_PATCH_SET_UPDATE_:_',''),'DATABASE_PATCH_SET_UPDATE_','')||','||
'action_date="'||to_char(action_time,'DD/MM/RR_HH24:MI:SS')||'"'
from dba_registry_sqlpatch;
--where upper(description) like 'DATABASE PATCH SET UPDATE%';
EOF

elif [ ${DB_VERSION%.*.*.*} == "12.2" ]; then
sqlplus -s / as sysdba <<EOF > .dbmetric_patch_$ORACLE_SID
set lines 200
set pages 500
set head off
set timi off
set time off
set echo off
set feedback off
select 
'patch='||replace(replace(replace(upper(description),' ','_'),'DATABASE_RELEASE_:_',''),'DATABASE_RELEASE_','')||','||
'action_date="'||to_char(action_time,'DD/MM/RR_HH24:MI:SS')||'"'
from dba_registry_sqlpatch;
--where upper(description) like 'DATABASE RELEASE%';
EOF
else #11G
sqlplus -s / as sysdba <<EOF > .dbmetric_patch_$ORACLE_SID
set lines 200
set pages 500
set head off
set timi off
set time off
set echo off
set feedback off
select
'patch='||replace(comments,' ','_')||','||
'action_date="'||to_char(max(action_time),'DD/MM/RR_HH24:MI:SS')||'"'
from registry\$history
--where comments like '%PSU%'
group by comments;
EOF
fi

for rowdb in $(cat .dbmetric_patch_$ORACLE_SID|grep "\S")
do
  keytag=$(echo $rowdb |cut -d',' -f1)
  keyvalue=$(echo $rowdb |cut -d',' -f2-)
  echo "patch,host="$HOSTNAME",db="$ORACLE_SID","$keytag" "$keyvalue
done;
#FIM PATCH

#METRICS
sqlplus -s / as sysdba <<EOF > .dbmetric_dbm_$ORACLE_SID
set lines 200
set pages 500
set head off
set timi off
set time off
set echo off
set feedback off
select 
'metric_name='||replace(metric_name,' ','_')||','||
'value='||ROUND(value, 1)||','||
'metric_unit="'||replace(metric_unit,' ','_')||'"'
from v\$SYSMETRIC
where metric_name in  (
'User Calls Per Sec',
'User Commits Per Sec',
'User Rollbacks Per Sec',
'User Transaction Per Sec',
'Average Active Sessions',
'Current Logons Count',
'Active Parallel Sessions',
'PQ Slave Session Count',
'PQ QC Session Count',
'Process Limit %',
'Session Limit %',
'Redo Generated Per Sec',
'Redo Writes Per Sec',
'Session Count',
'Database Time Per Sec',
'Executions Per User Call',
'Response Time Per Txn',
'Physical Read Total Bytes Per Sec',
'Physical Write Total Bytes Per Sec',
'Physical Read Total IO Requests Per Sec',
'Physical Read IO Requests Per Sec',
'I/O Megabytes per Second',
'CPU Usage Per Sec',
'Current OS Load',
'Background CPU Usage Per Sec',
'Global Cache Blocks Lost',
'Network Traffic Volume Per Sec',
'Logons Per Sec',
'Average Synchronous Single-Block Read Latency',
'Hard Parse Count Per Sec',
'Global Cache Average CR Get Time',
'Global Cache Average Current Get Time'
)
and group_id=2;
EOF
#FIM DBMETRICS

for rowdb in $(cat .dbmetric_dbm_$ORACLE_SID|grep "\S")
do
  keytag=$(echo $rowdb |cut -d',' -f1)
  keyvalue=$(echo $rowdb |cut -d',' -f2-)
  echo "dbmetrics,host="$HOSTNAME",db="$ORACLE_SID","$keytag" "$keyvalue
done;

#WAIT_CLASS
sqlplus -s / as sysdba <<EOF > .dbmetric_wc_$ORACLE_SID
set lines 200
set pages 500
set head off
set timi off
set time off
set echo off
set feedback off
select 
'wait_class='||replace(n.wait_class,' ','_')||','||
'total_aas='||round(m.time_waited/m.INTSIZE_CSEC,3)
--n.wait_class, round(m.time_waited/m.INTSIZE_CSEC,3) AAS
from   v\$waitclassmetric  m, v\$system_wait_class n
where m.wait_class_id=n.wait_class_id and n.wait_class != 'Idle'
union
select  
'wait_class=CPU,'||
'total_aas='||round(value/100,3)
--'CPU', round(value/100,3) AAS
from v\$sysmetric where metric_name='CPU Usage Per Sec' and group_id=2;
EOF
#FIM WAIT_CLASS

for rowdb in $(cat .dbmetric_wc_$ORACLE_SID|grep "\S")
do
  keytag=$(echo $rowdb |cut -d',' -f1)
  keyvalue=$(echo $rowdb |cut -d',' -f2-)
  echo "waitclass,host="$HOSTNAME",db="$ORACLE_SID","$keytag" "$keyvalue
done;

#DB EVENT
sqlplus -s / as sysdba <<EOF > .dbmetric_dbe_$ORACLE_SID
set lines 200
set pages 500
set head off
set timi off
set time off
set echo off
set feedback off
select * from (
select 
'event_name='||replace(n.name,' ','_')||','||
'time_waited_s='||round(m.time_waited/100,2)||','||
'wait_count='||replace(m.wait_count,' ','_')||','||
'avg_ms='||nvl(round(10*m.time_waited/nullif(m.wait_count,0),3),0)
from v\$eventmetric m,
     v\$event_name n
where m.event_id=n.event_id
and wait_class#!=6
order by time_waited desc)
where rownum <30;
EOF
#DB EVENT

for rowdb in $(cat .dbmetric_dbe_$ORACLE_SID|grep "\S")
do
  keytag=$(echo $rowdb |cut -d',' -f1)
  keyvalue=$(echo $rowdb |cut -d',' -f2-)
  echo "db_event,host="$HOSTNAME",db="$ORACLE_SID","$keytag" "$keyvalue
done;

#PGA
sqlplus -s / as sysdba <<EOF > .dbmetric_pga_$ORACLE_SID
set lines 200
set pages 500
set head off
set timi off
set time off
set echo off
set feedback off
select 'pga_total_mb='||nvl(PGA_LIMIT,PGA_TARGET)||','||
'pga_used_mb='||PGA_USED_MB||','||
'pga_alloc_mb='||pga_alloc_mb
from (
select round(sum(p.PGA_USED_MEM)/1024/1024,1) "PGA_USED_MB",
round(sum(p.PGA_ALLOC_MEM)/1024/1024,1) "PGA_ALLOC_MB",
max((select value/1024/1024 "PGA_TOTAL_LIMIT" from v\$parameter where name ='pga_aggregate_limit')) "PGA_LIMIT",
max((select value/1024/1024 "PGA_TOTAL_LIMIT" from v\$parameter where name ='pga_aggregate_target')) "PGA_TARGET"
from v\$process p);
EOF
#FIM PGA

for rowdb in $(cat .dbmetric_pga_$ORACLE_SID|grep "\S")
do
  #keytag=$(echo $rowdb |cut -d',' -f1)
  #keyvalue=$(echo $rowdb |cut -d',' -f2-)
  echo "db_pga,host="$HOSTNAME",db="$ORACLE_SID" "$rowdb
done;


#SGA
sqlplus -s / as sysdba <<EOF > .dbmetric_sga_$ORACLE_SID
set lines 200
set pages 500
set head off
set timi off
set time off
set echo off
set feedback off
--dinamic comp
select 
'component='||replace(replace(component,' ','_'),'DEFAULT_buffer_cache','buffer_cache')||','||
'size='||max(final_size)
from V\$SGA_RESIZE_OPS a
where start_time=(select max(start_time) from V\$SGA_RESIZE_OPS b where b.component=a.component)
group by component
union
--fixed comp
select 
'component='||replace(replace(name,'Maximum SGA Size','sga_max_size'),' ','_')||','||
'size='||bytes
from v\$sgainfo where name ='Maximum SGA Size' or name ='Redo Buffers';

EOF
#FIM SGA

for rowdb in $(cat .dbmetric_sga_$ORACLE_SID|grep "\S")
do
  keytag=$(echo $rowdb |cut -d',' -f1)
  keyvalue=$(echo $rowdb |cut -d',' -f2-)
  echo "db_sga,host="$HOSTNAME",db="$ORACLE_SID","$keytag" "$keyvalue
done;


done ##FIM DO FOR DE BANCO