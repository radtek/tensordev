#! /usr/bin/env bash
#exec_db_check.sh
#Objetivo: Coleta de health check de banco de dados
# 
# -> REVISOES
#    19/11/2019  -  Criacao                                                     -   jose.juliano@telefonica.com
#    06/12/2019  -  Alteracao para trabalhar com varias NICs                    -   jose.juliano@telefonica.com
#    09/12/2019  -  Verifica se ha parametro duplicado no sysctl                -   jose.juliano@telefonica.com
#    10/12/2019  -  Verifica multipath e valida asmlib config                   -   jose.juliano@telefonica.com
#    21/01/2020  -  Adicionado funcao de update do oratab                       -   jose.juliano@telefonica.com
#REFERENCEs
#rp_filter for multiple private interconnects and Linux Kernel 2.6.32+ (Doc ID 1286796.1)
#Oracle Database (RDBMS) on Unix AIX,HP-UX,Linux,Mac OS X,Solaris,Tru64 Unix Operating Systems Installation and Configuration Requirements Quick Reference (8.0.5 to 11.2) (Doc ID 169706.1)
#Health Check Alert: Set SHMMAX greater than or equal to the recommended minimum value (Doc ID 957520.1)
#ORA-04031 on ASM Instance - default memory parameters for 11.2 ASM instances are too low (Doc ID 1536039.1)
#set -o errexit
#set -o pipefail
#set -x

#ROADMAP DEV
#12cR2 optimizer_adaptive_features foi desmembrado em 2 parametros
# NTP
# BCT ativo
# FERRAMENTAS
# PARAMETROS INVISIVEIS
# TMP.CONF  e LOGIND.CONF
# verificar area de archive contempla 2 dias
# verificar compatible dos diskgroups se esta na versao corrente

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
OUTPUT_FILE=hcdb
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
##FUNCTION
fn_output_csv ()
{
  ##Percorre todos os argumentos passados e gera linha unica com formato CSV
  for i in $(seq 1 $#); do
   eval "arg=\${$i}"
   if [ $i -eq $# ]; then
     RESULTADO=$RESULTADO"\""$arg"\""
   else
     RESULTADO=$RESULTADO"\""$arg"\"|"
   fi
  done
  echo $RESULTADO >> $FULL_OUTPUT_DIR.csv
  unset RESULTADO
}
fn_printcol()
{
  COL1=$1
  COL2=$2
  COL3=$3
  COL4=$4
  printf "%-.30s%s\n" "$COL1................................" ": $COL2 $COL3 $COL4"
}

fn_debug()
{
  COL1=$1
  echo $COL1
  read -p "<Aperte enter para continuar>"
}

fn_titulo()
{
  TITULO=$1
  let secao_count++
  echo
  printf "%-.85s%s\n" "-----------------------------------------------------------------------------------"
  printf "%-.82s%s\n" "|                                                                                                        " "|"
  printf "%-.82s%s\n" "| #$secao_count $TITULO                                                                                       " "|"
  printf "%-.82s%s\n" "|                                                                                                        " "|"
  printf "%-.85s%s\n" "-----------------------------------------------------------------------------------"
  echo
  
}

fn_subtitulo()
{
  TITULO=$1
  let subsecao_count++
  echo
  printf "%-.60s%s\n" "------------------------------------------------------------"
  printf "%-.59s%s\n" "| #$secao_count.$subsecao_count $TITULO                                                           " "|"
  printf "%-.60s%s\n" "------------------------------------------------------------"
  echo
}

fn_sumariza_erro()
{
let sumariza_erro_count++
SUMARIZA_ERRO[$sumariza_erro_count]="$secao_count.$subsecao_count $1"
}

fn_update_oratab(){
for i in $(ps -ef | grep pmon | egrep -v "grep|APX|MGMTDB" | awk {' print $2 "|" substr($8,10) '}); do
ORACLEPID=$(echo $i|cut -d"|" -f1)
ORACLESID=$(echo $i|cut -d"|" -f2)
ORACLEHOME=$(strings /proc/$ORACLEPID/environ |grep -i ORACLE_HOME|cut -d"=" -f2)
#echo -e "ORACLE_PID="${ORACLE_PID}" ORACLE_SID="${ORACLE_SID}" ORACLE_HOME="${ORACLE_HOME}"\n"  
ORATABROW=${ORACLESID}":"${ORACLEHOME}:"N"

if [ -f "/etc/oratab" ]; then
  #achou o oratab
  ROWCOUNT=$(cat /etc/oratab |grep "^${ORATABROW}"|wc -l)
  if [ "$ROWCOUNT" -eq "0" ]; then
    #nao encontrou a linha 
	echo ${ORATABROW} >> /etc/oratab
	echo ${ORATABROW}
  fi;
else
  echo -e "\nERROR: Arquivo /etc/oratab nao existe no servidor $HOSTNAME"
  exit;
fi
  
done;

}

fn_inicializa()
{
  user_error=0
  #sai com erro se usuario nao for o dono do banco
  for i in $(ps -ef | grep pmon | egrep -v "ASM|grep|APX|MGMTDB" | awk {' print $1 '} |sort -u); 
  do
      if [ $USER = "$i" ]; then
        let user_error++
      fi;
  done;  
  if [ "$user_error" = "0" ]; then
    echo -e "\nERROR: Somente o usuario dono do banco pode executar esse script\n"
    exit 1
  fi; 
  
  ##muda para diretorio sh
  cd $SH_DIR
  
  ##cria diretorio e/ou arquivos necessarios para execucao do script
  if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
  fi

  ##Cria cabecalho do arquivo csv
  echo "SERVIDOR|SECAO|SUBSECAO|CHAVE|VALOR|SCORE" > $FULL_OUTPUT_DIR.csv
  $(rm .hcdb_* 2>/dev/null)
}

##Inicializa arquivos e diretorios
fn_inicializa
#fn_update_oratab

##INICIO DO SCRIPT DE HEALTHCHECK
echo
echo "        STARTING HEALTHCHECK    $(date)  "

#imprime titulo
fn_titulo "EXECUTANDO CHECK DIVERSOS"

###################imprime subtitulo
fn_subtitulo "Verifica usuario AUTOMATA"

GIT=$(grep -i automata /etc/passwd)
if [ $? -eq "0" ]; then ##nao gerou erro, usuario encontrado
 fn_printcol "AUTOMATA" "$GIT"
 echo -e "\nSUCCESS: Usuario automata encontrado"
else #erro encontrado, usuario nao existe
 echo -e "\nERROR: Usuario automata nao existe no servidor $HOSTNAME"
 let sumariza_erro++
fi
#ENCONTROU ERRO
if [ $sumariza_erro -gt "0" ]; then
  fn_sumariza_erro "Usuario automata nao existe no servidor $HOSTNAME"
fi;
sumariza_erro=0
#Resultado CSV
fn_output_csv "$HOSTNAME" "DIVERSOS" "GIT" "GIT" "$GIT" "$SCORE"
#--FIM--

###################imprime subtitulo
fn_subtitulo "Verifica mountpoint"

for i in $(echo -e "/dbs/manobra\n/dbs/trace\n/dbs/tools\n/u01\n/oem/agent\n/oracle/admin/scripts")
do 
  fn_printcol "Checando filesystem" "$i"
  #echo -e "\nChecando filesystem..: "$i
  DF=$(df -Ph $i 2>/dev/null)
  if [ $? != 0 ]; then
	  #echo "FS nao existe: "$i
    NOFS=$(echo "$i\n")$NOFS
  else ##pode haver pasta criada mas sem mountpoint
     NEWDF=$(df -Ph $i 2>/dev/null |grep -v Mounted |awk {' print $6 '} )
	   #echo "Mountpoint...: "$NEWDF "para diretorio: "$i
	   if [ "$NEWDF" != "$i" ]; then
	     NUMNF=$(echo "$i\n")$NUMNF
	   fi
  fi
done
#Resultado CSV
fn_output_csv "$HOSTNAME" "DIVERSOS" "MOUNTPOINT" "DATA" "$NUMNF" 
if [ -z "$NUMNF" ]; then ##nao existe mountpoint errado
  echo -e "\nSUCCESS: Nenhum diretorio sem mountpoint encontrado"
else
  let sumariza_erro++
  echo -e "\nERROR: Encontrado diretorio sem mountpoint criado"
  echo
  echo -e $NUMNF
  #echo -e $NOFS
fi
#ENCONTROU ERRO
if [ $sumariza_erro -gt "0" ]; then
  fn_sumariza_erro "Encontrado diretorio sem mountpoint criado"
fi;
sumariza_erro=0
#--FIM--

###################imprime subtitulo
fn_subtitulo "Verifica instalacao do git"

GIT_VERSION=$(git --version 2>/dev/null)
if [ $? -eq "0" ]; then ##nao gerou erro
 fn_printcol "GIT" "$GIT_VERSION"
 echo -e "\nSUCCESS: GIT ENCONTRADO"
else #erro encontrado, usuario nao existe
 let sumariza_erro++
 echo -e "\nERROR: GIT nao encontrado ou fora do PATH"
 GIT_VERSION="NOTFOUND"
fi
#ENCONTROU ERRO
if [ $sumariza_erro -gt "0" ]; then
  fn_sumariza_erro "GIT nao encontrado ou fora do PATH"
fi;
sumariza_erro=0
#Resultado CSV
fn_output_csv "$HOSTNAME" "DIVERSOS" "GIT" "GIT" "$GIT_VERSION" "$SCORE"
#--FIM--

###################imprime titulo
fn_titulo "EXECUTANDO CHECK DB"

###################imprime subtitulo
fn_subtitulo "Verifica Parametros de banco"

##EXECUTA PARA CADA PMON ENCONTRADO
for i in $(ps -ef | grep pmon | egrep -v "ASM|grep|APX|MGMTDB" | awk {' print substr($8,10) '}); do
  ##VARs
  ORACLE_SID=$i
  ORACLE_USER=$(ps -ef | grep pmon | grep $i | grep -v grep | grep -v ASM | awk '{ print $1 }')
  ORAENV_ASK=NO
  . oraenv 1>/dev/null <<EOF
$ORACLE_SID
EOF
##CAPTURA VERSAO DO BANCO
sqlplus -s / as sysdba <<EOF > .hcdb_dbversion_$ORACLE_SID
set lines 200
set pages 500
set head off
set timi off
set time off
select substr(banner,instr(banner,' ',1, 6)+1,10) from v\$version where rownum <2;
EOF

DB_VERSION=$(cat .hcdb_dbversion_$ORACLE_SID|tr -d '\n')

##CAPTURA SGA MAIOR QUE 100G
sqlplus -s / as sysdba <<EOF > .hcdb_dbsgasize_$ORACLE_SID
set head off
set serveroutput on
set feedback off
set timi off
set time off
declare
n_valor   number;
begin
  for reg in (SELECT value FROM v\$parameter where name in ('sga_max_size','sga_target','memory_max_target','memory_target'))
  loop
    if reg.value >= 107374182400 /*100gb*/ then
	  n_valor:=reg.value;
      
    end if;
  end loop;
  dbms_output.put_line(n_valor);
end;
/
EOF

SGA_100G=$(cat .hcdb_dbsgasize_$ORACLE_SID|tr -d '\n')

##CAPTURA PARAMETROS DO BANCO
sqlplus -s / as sysdba <<EOF > .hcdb_dbparameters_$ORACLE_SID
set lines 200
set pages 500
col name for a60
col value for a120
set head off
select name,upper(value) value from v\$parameter order by 1;
EOF

cpu_count=$(cat /proc/cpuinfo | grep -i processor | tail -1 | sed -n "s/://p" | awk {' print $2+1 '})
parallel_max_servers=$(awk -v cpu_count="${cpu_count}" 'BEGIN{print (2*cpu_count*3)}')

#DEFINE VALOR DE PARAMETROS POR VERSAO DE BANCO
if [ ${DB_VERSION%.*.*.*} == "12.1" ]; then
  optimizer_adaptive_features="echo \"optimizer_adaptive_features|==|FALSE\">>.hcdb_dbparamref_$ORACLE_SID"
  pga_aggregate_limit="echo \"pga_aggregate_limit|-gt|0\">>.hcdb_dbparamref_$ORACLE_SID"
  pre_page_sga="echo \"pre_page_sga|==|TRUE\">>.hcdb_dbparamref_$ORACLE_SID"
elif [ ${DB_VERSION%.*.*.*} == "12.2" ]; then
  optimizer_adaptive_features="echo \"optimizer_adaptive_features|==|TRUE\">>.hcdb_dbparamref_$ORACLE_SID"
  pga_aggregate_limit="echo \"pga_aggregate_limit|-gt|0\">>.hcdb_dbparamref_$ORACLE_SID"
  pre_page_sga="echo \"pre_page_sga|==|TRUE\">>.hcdb_dbparamref_$ORACLE_SID"
else
  optimizer_adaptive_features="echo \"optimizer_adaptive_features|==|NOTSET\">>.hcdb_dbparamref_$ORACLE_SID"
  pga_aggregate_limit="echo \"pga_aggregate_limit|==|NOTSET\">>.hcdb_dbparamref_$ORACLE_SID"
  pre_page_sga="echo \"pre_page_sga|==|FALSE\">>.hcdb_dbparamref_$ORACLE_SID"
fi

#Adiciona parametros caso SGA>100G
if [ ! -z "$SGA_100G" ]; then
 gc_policy_minimum="echo \"_gc_policy_minimum|==|15000\">>.hcdb_dbparamref_$ORACLE_SID" 
 lm_sync_timeout="echo \"_lm_sync_timeout|==|1200\">>.hcdb_dbparamref_$ORACLE_SID"
 lm_tickets="echo \"_lm_tickets|==|5000\">>.hcdb_dbparamref_$ORACLE_SID"
 shared_pool_size="echo \"shared_pool_size|-ge|37580963840\">>.hcdb_dbparamref_$ORACLE_SID"
else
  shared_pool_size="echo \"shared_pool_size|-gt|0\">>.hcdb_dbparamref_$ORACLE_SID" 
fi
#[[ ( ! -z $SGA_100G && $RAC_FOUND == "0" ) ]];

#Altera valor caso seja RAC
if [ "$RAC_FOUND" == "0" ]; then
  gcs_server_processes="echo \"gcs_server_processes|==|0\">>.hcdb_dbparamref_$ORACLE_SID"
else
  if [ ! -z "$SGA_100G" ]; then
    gcs_server_processes="echo \"gcs_server_processes|==|8\">>.hcdb_dbparamref_$ORACLE_SID"
  else 
    gcs_server_processes="echo \"gcs_server_processes|-gt|0\">>.hcdb_dbparamref_$ORACLE_SID"
  fi
  
fi

##CONFIG
echo "db_block_checksum|==|TYPICAL">>.hcdb_dbparamref_$ORACLE_SID
echo "db_lost_write_protect|==|NONE">>.hcdb_dbparamref_$ORACLE_SID
echo "compatible|==|$DB_VERSION">>.hcdb_dbparamref_$ORACLE_SID
echo "deferred_segment_creation|==|TRUE">>.hcdb_dbparamref_$ORACLE_SID
echo "log_checkpoints_to_alert|==|TRUE">>.hcdb_dbparamref_$ORACLE_SID
echo "commit_logging|==|NOTSET">>.hcdb_dbparamref_$ORACLE_SID
echo "commit_wait|==|NOTSET">>.hcdb_dbparamref_$ORACLE_SID
echo "recyclebin|==|OFF">>.hcdb_dbparamref_$ORACLE_SID
##OPTIMIZER
echo "optimizer_index_caching|==|0">>.hcdb_dbparamref_$ORACLE_SID
echo "optimizer_index_cost_adj|==|100">>.hcdb_dbparamref_$ORACLE_SID
echo "optimizer_features_enable|==|${DB_VERSION%.*}">>.hcdb_dbparamref_$ORACLE_SID
echo "optimizer_mode|==|ALL_ROWS">>.hcdb_dbparamref_$ORACLE_SID
echo "optimizer_use_invisible_indexes|==|FALSE">>.hcdb_dbparamref_$ORACLE_SID
echo "optimizer_use_sql_plan_baselines|==|TRUE">>.hcdb_dbparamref_$ORACLE_SID
echo "optimizer_use_pending_statistics|==|FALSE">>.hcdb_dbparamref_$ORACLE_SID
echo "optimizer_capture_sql_plan_baselines|==|FALSE">>.hcdb_dbparamref_$ORACLE_SID
echo "optimizer_dynamic_sampling|-le|2">>.hcdb_dbparamref_$ORACLE_SID
eval $optimizer_adaptive_features
##SGA
echo "memory_max_target|==|0">>.hcdb_dbparamref_$ORACLE_SID
echo "memory_target|==|0">>.hcdb_dbparamref_$ORACLE_SID
echo "sga_target|-gt|0">>.hcdb_dbparamref_$ORACLE_SID
echo "sga_max_size|-gt|0">>.hcdb_dbparamref_$ORACLE_SID
eval $pga_aggregate_limit
echo "pga_aggregate_target|-gt|0">>.hcdb_dbparamref_$ORACLE_SID
eval $shared_pool_size
echo "shared_pool_reserved_size|-gt|0">>.hcdb_dbparamref_$ORACLE_SID
echo "db_cache_size|-gt|0">>.hcdb_dbparamref_$ORACLE_SID
echo "log_buffer|-gt|0">>.hcdb_dbparamref_$ORACLE_SID
echo "lock_sga|==|FALSE">>.hcdb_dbparamref_$ORACLE_SID
eval $pre_page_sga
echo "streams_pool_size|-ge|1073741824">>.hcdb_dbparamref_$ORACLE_SID
echo "large_pool_size|-ge|536870912">>.hcdb_dbparamref_$ORACLE_SID
eval $gc_policy_minimum
eval $lm_sync_timeout
eval $lm_tickets
eval $gcs_server_processes
#CAPACITY 
echo "cpu_count|-le|$cpu_count">>.hcdb_dbparamref_$ORACLE_SID
echo "open_cursors|-ge|1000">>.hcdb_dbparamref_$ORACLE_SID
echo "sessions|-ge|300">>.hcdb_dbparamref_$ORACLE_SID
echo "processes|-ge|1000">>.hcdb_dbparamref_$ORACLE_SID
echo "db_files|-ge|5000">>.hcdb_dbparamref_$ORACLE_SID
echo "session_cached_cursors|-ge|50">>.hcdb_dbparamref_$ORACLE_SID
#TUNING
echo "statistics_level|==|TYPICAL">>.hcdb_dbparamref_$ORACLE_SID
echo "result_cache_mode|==|MANUAL">>.hcdb_dbparamref_$ORACLE_SID
echo "cursor_sharing|==|EXACT">>.hcdb_dbparamref_$ORACLE_SID
echo "resource_limit|==|FALSE">>.hcdb_dbparamref_$ORACLE_SID
echo "resource_manager_cpu_allocation|-le|$cpu_count">>.hcdb_dbparamref_$ORACLE_SID
echo "use_large_pages|==|ONLY">>.hcdb_dbparamref_$ORACLE_SID
echo "db_file_multiblock_read_count|==|128">>.hcdb_dbparamref_$ORACLE_SID
echo "log_checkpoint_interval|==|180">>.hcdb_dbparamref_$ORACLE_SID
#PARALLEL
echo "parallel_max_servers|-le|$parallel_max_servers">>.hcdb_dbparamref_$ORACLE_SID
echo "parallel_threads_per_cpu|==|2">>.hcdb_dbparamref_$ORACLE_SID
echo "parallel_degree_policy|==|MANUAL">>.hcdb_dbparamref_$ORACLE_SID
echo "parallel_adaptive_multi_user|==|TRUE">>.hcdb_dbparamref_$ORACLE_SID

#check
  for hcdb_dbparameters in $(ls .hcdb_dbparameters_$ORACLE_SID)
  do
    printf "%- 10s %- 40s%-20s %s\n" "DBNAME" "PARAMETRO" "VALOR ATUAL" "STATUS"
    printf "%- 10s %- 40s%-20s %s\n" "----------" "---------------------------------------" "--------------------" "--------------"
    for parameter_row in $(cat .hcdb_dbparamref_$ORACLE_SID)
    do
      #VALORES DE REFERENCIA
      REF_VALUE=$(echo $parameter_row |cut -d"|" -f3)
      REF_CONDI=$(echo $parameter_row |cut -d"|" -f2)
      REF_PARAM=$(echo $parameter_row |cut -d"|" -f1)
      #VALORES ATUAIS
      CURRENT_VALUE=$(grep -i -w $REF_PARAM $hcdb_dbparameters |awk {'print $2'})
      CURRENT_NAME=$(grep -i -w $REF_PARAM $hcdb_dbparameters |awk {'print $1'})
      DB=$(echo $hcdb_dbparameters |cut -f 3 -d '_')
      #echo $DB": "$VAR
      if [ -z "$CURRENT_VALUE" ]; then
        CURRENT_VALUE='NOTSET'
      fi
      CHECKING=$(echo "[[ " \"$CURRENT_VALUE\"\ "$REF_CONDI" \"$REF_VALUE\"\ " ]]")
      #echo $CHECKING
      #read -p "ENTER"
      if eval "$CHECKING" ; then
        VALUE_ERROR="SUCCESS"
      else
        VALUE_ERROR="ERROR: $REF_CONDI $REF_VALUE"
        let sumariza_erro++
      fi
      #read -p "ENTER"
      printf "%- 10s %- 40s%-20s %s\n" "$DB" "$REF_PARAM" "$CURRENT_VALUE" "$VALUE_ERROR"
      ##CALCULA VALOR AGREGADO DE PARAMETROS
      if [ ! -z  "$CURRENT_NAME" ] && [ "$CURRENT_NAME" == "sga_max_size" ]; then
        SOMA_SGA=$(awk -v soma="${SOMA_SGA}" -v current_value="${CURRENT_VALUE}" 'BEGIN{print (soma+current_value)}')
      elif [ ! -z  "$CURRENT_NAME" ] && [ "$CURRENT_NAME" == "pga_aggregate_limit" ] && [ ${DB_VERSION%.*.*.*.*} == "12" ]; then
        SOMA_PGA=$(awk -v soma="${SOMA_PGA}" -v current_value="${CURRENT_VALUE}" 'BEGIN{print (soma+current_value)}')      
      elif [ ! -z  "$CURRENT_NAME" ] && [ "$CURRENT_NAME" == "pga_aggregate_target" ] && [ ${DB_VERSION%.*.*.*.*} == "11" ]; then
        SOMA_PGA=$(awk -v soma="${SOMA_PGA}" -v current_value="${CURRENT_VALUE}" 'BEGIN{print (soma+current_value)}')  
      elif [ ! -z  "$CURRENT_NAME" ] && [ "$CURRENT_NAME" == "cpu_count" ]; then
        SOMA_CPU=$(awk -v soma="${SOMA_CPU}" -v current_value="${CURRENT_VALUE}" 'BEGIN{print (soma+current_value)}')      
      elif [ ! -z  "$CURRENT_NAME" ] && [ "$CURRENT_NAME" == "gcs_server_processes" ]; then
        SOMA_GCS=$(awk -v soma="${SOMA_GCS}" -v current_value="${CURRENT_VALUE}" 'BEGIN{print (soma+current_value)}')      
      elif [ ! -z  "$CURRENT_NAME" ] && [ "$CURRENT_NAME" == "parallel_max_servers" ]; then
        SOMA_PARALLEL_MAX_SERVERS=$(awk -v soma="${SOMA_PARALLEL_MAX_SERVERS}" -v current_value="${CURRENT_VALUE}" 'BEGIN{print (soma+current_value)}') 
      elif [ ! -z  "$CURRENT_NAME" ] && [ "$CURRENT_NAME" == "processes" ]; then
        SOMA_PROCESSES=$(awk -v soma="${SOMA_PROCESSES}" -v current_value="${CURRENT_VALUE}" 'BEGIN{print (soma+current_value)}') 
      fi
    done
   echo
  done;
echo -e "SOMA_SGA: "$SOMA_SGA"kb SOMA_PGA: "$SOMA_PGA "kb SOMA_CPU: "$SOMA_CPU " SOMA_GCS: "$SOMA_GCS"\n"
#ENCONTROU ERRO
if [ $sumariza_erro -gt "0" ]; then
  fn_sumariza_erro "Erros encontrados ao verificar parametros do banco $ORACLE_SID"
fi;
sumariza_erro=0
unset VALUE_ERROR
#--FIM--


done
#--FIM--

###################imprime titulo
fn_titulo "EXECUTANDO CHECAGEM NO SO"

###################imprime subtitulo
fn_subtitulo "Coleta dados de memoria"

MEMTOTAL=$(cat /proc/meminfo | grep -i MemTotal | sed -n "s/://p" | awk {' print $2 '})
MEMFREE=$(cat /proc/meminfo | grep -i MemFree | sed -n "s/://p" | awk {' print $2 '})
SWAPTOTAL=$(cat /proc/meminfo | grep -i SwapTotal | sed -n "s/://p" | awk {' print $2 '})
SWAPFREE=$(cat /proc/meminfo | grep -i SwapFree | sed -n "s/://p" | awk {' print $2 '})
ANONHUP=$(cat /proc/meminfo | grep -i AnonHugePages | sed -n "s/://p" | awk {' print $2 '})
HPTOTAL=$(cat /proc/meminfo | grep -i HugePages_Total | sed -n "s/://p" | awk {' print $2 '})
HPFREE=$(cat /proc/meminfo | grep -i HugePages_Free | sed -n "s/://p" | awk {' print $2 '})
HPSIZE=$(cat /proc/meminfo | grep -i Hugepagesize | sed -n "s/://p" | awk {' print $2 '})
#if [ $OS_VERSION -gt "5" ]; then $ANONHUP; else ANONHUP="NOTSET"; fi
if [ -z $ANONHUP ]; then ANONHUP="NOTSET"; fi ##HUGEPAGE habilitado OS>5

#DISPLAY
fn_printcol "Memtotal" "$(echo $MEMTOTAL | awk {' printf("%.2fGB\n",($1/1024/1024)) '})"
fn_printcol "Memfree" "$(echo $MEMFREE | awk {' printf("%.2fGB\n",($1/1024/1024)) '})"
fn_printcol "Swaptotal" "$(echo $SWAPTOTAL | awk {' printf("%.2fGB\n",($1/1024/1024)) '})"
fn_printcol "Swapfree" "$(echo $SWAPFREE | awk {' printf("%.2fGB\n",($1/1024/1024)) '})"
fn_printcol "AnonHugePages" "$(echo $ANONHUP | awk -v hpsize="$HPSIZE" {' printf("%.2fGB\n",(($1*hpsize)/1024/1024)) '})"
fn_printcol "HugePages_Total" "$(echo $HPTOTAL | awk -v hpsize="$HPSIZE" {' printf("%.2fGB\n",(($1*hpsize)/1024/1024)) '})" 
fn_printcol "HugePages_Free" "$(echo $HPFREE | awk -v hpsize="$HPSIZE" {' printf("%.2fGB\n",(($1*hpsize)/1024/1024)) '}) "
fn_printcol "Hugepagesize" "$HPSIZE"

#RESULTADO CSV
fn_output_csv "$HOSTNAME" "OS" "MEMORY" "Memtotal" $MEMTOTAL ""
fn_output_csv "$HOSTNAME" "OS" "MEMORY" "Memfree" $MEMFREE ""
fn_output_csv "$HOSTNAME" "OS" "MEMORY" "Swaptotal" $SWAPTOTAL ""
fn_output_csv "$HOSTNAME" "OS" "MEMORY" "Swapfree" $SWAPFREE ""
fn_output_csv "$HOSTNAME" "OS" "MEMORY" "AnonHugePages" $ANONHUP ""
fn_output_csv "$HOSTNAME" "OS" "MEMORY" "HugePages_Total" $HPTOTAL ""
fn_output_csv "$HOSTNAME" "OS" "MEMORY" "HugePages_Free" $HPFREE ""
fn_output_csv "$HOSTNAME" "OS" "MEMORY" "HPHugepagesize" $HPSIZE ""

###################imprime subtitulo
fn_subtitulo "Coleta dados de CPU"
PROC=$(cat /proc/cpuinfo | grep -i processor | tail -1 | sed -n "s/://p" | awk {' print $2+1 '})
fn_printcol "CPUTOTAL" "$PROC"
fn_output_csv "$HOSTNAME" "OS" "CPU" "CPUTOTAL" $PROC ""
#--FIM

###################imprime subtitulo
fn_subtitulo "Coleta SYSCTL.CONF"

SYSCTL[1]=$(cat /etc/sysctl.conf |grep -v "#" | egrep "kernel.shmall" | sed -n "s/=/ /p" | awk {' print $2 '})
SYSCTL[2]=$(cat /etc/sysctl.conf |grep -v "#" | egrep "kernel.shmmax" | sed -n "s/=/ /p" | awk {' print $2 '})
SYSCTL[3]=$(cat /etc/sysctl.conf |grep -v "#" | egrep "kernel.sem" | sed -n "s/=//p" | sed -n "s/kernel.sem//p" | sed -n "s/ //p")
SYSCTL[4]=$(cat /etc/sysctl.conf |grep -v "#" | egrep "kernel.shmmni" | sed -n "s/=/ /p" | awk {' print $2 '})
SYSCTL[5]=$(cat /etc/sysctl.conf |grep -v "#" | egrep "net.ipv4.ip_local_port_range" | sed -n "s/=/ /p" | sed -n "s/net.ipv4.ip_local_port_range//p")
SYSCTL[6]=$(cat /etc/sysctl.conf |grep -v "#" | egrep "net.core.rmem_default" | sed -n "s/=/ /p" | awk {' print $2 '})
SYSCTL[7]=$(cat /etc/sysctl.conf |grep -v "#" | egrep "net.core.rmem_max" | sed -n "s/=/ /p" | awk {' print $2 '})
SYSCTL[8]=$(cat /etc/sysctl.conf |grep -v "#" | egrep "net.core.wmem_default" | sed -n "s/=/ /p" | awk {' print $2 '})
SYSCTL[9]=$(cat /etc/sysctl.conf |grep -v "#" | egrep "net.core.wmem_max" | sed -n "s/=/ /p" | awk {' print $2 '})
SYSCTL[10]=$(cat /etc/sysctl.conf |grep -v "#" | egrep "fs.aio-max-nr" | sed -n "s/=/ /p" | awk {' print $2 '})
SYSCTL[11]=$(cat /etc/sysctl.conf |grep -v "#" | egrep "fs.file-max" | sed -n "s/=/ /p" | awk {' print $2 '})
SYSCTL[12]=$(cat /etc/sysctl.conf |grep -v "#" | egrep "vm.nr_hugepages" | sed -n "s/=/ /p" | awk {' print $2 '})
SYSCTL[13]=$(cat /etc/sysctl.conf |grep -v "#" | egrep "net.ipv4.ipfrag_high_thresh" | sed -n "s/=/ /p" | awk {' print $2 '})
SYSCTL[14]=$(cat /etc/sysctl.conf |grep -v "#" | egrep "net.ipv4.ipfrag_low_thresh" | sed -n "s/=/ /p" | awk {' print $2 '})

SYSCTL_PARAM[1]="kernel.shmall"
SYSCTL_PARAM[2]="kernel.shmmax"
SYSCTL_PARAM[3]="kernel.sem"
SYSCTL_PARAM[4]="kernel.shmmni"
SYSCTL_PARAM[5]="net.ipv4.ip_local_port_range"
SYSCTL_PARAM[6]="net.core.rmem_default"
SYSCTL_PARAM[7]="net.core.rmem_max"
SYSCTL_PARAM[8]="net.core.wmem_default"
SYSCTL_PARAM[9]="net.core.wmem_max"
SYSCTL_PARAM[10]="fs.aio-max-nr"
SYSCTL_PARAM[11]="fs.file-max"
SYSCTL_PARAM[12]="vm.nr_hugepages"
SYSCTL_PARAM[13]="net.ipv4.ipfrag_high_thresh"
SYSCTL_PARAM[14]="net.ipv4.ipfrag_low_thresh"

OSPAGESIZE=$(getconf PAGESIZE)
#($SOMA_SGA+5%)/$OSPAGESIZE
MIN_SHMALL=$(echo| awk -v sga="$SOMA_SGA" -v ospagesize="$OSPAGESIZE" 'BEGIN{ printf("%.f\n",(sga+(sga*0.02))/(ospagesize)) }')
#($MEMTOTAL*50%)/($OSPAGESIZE)
##MAX_SHMALL=$(echo| awk -v memtotal="$MEMTOTAL" -v ospagesize="$OSPAGESIZE" 'BEGIN{ printf("%.f\n",((memtotal*1024)*0.7)/(ospagesize)) }')
MAX_SHMALL=$(echo| awk -v memtotal="$MEMTOTAL" -v ospagesize="$OSPAGESIZE" 'BEGIN{ printf("%.f\n",((memtotal*1024))/(ospagesize)) }')

#($SOMA_SGA+5%)/($HPSIZE/1024)
MIN_NR_HUGEPAGES=$(echo| awk -v sga="$SOMA_SGA" -v hpsize="$HPSIZE" 'BEGIN{ printf("%.f\n",(sga+(sga*0.02))/(hpsize*1024)) }')
#($MEMTOTAL*50%)/($HPSIZE/1024)
MAX_NR_HUGEPAGES=$(echo| awk -v memtotal="$MEMTOTAL" -v hpsize="$HPSIZE" 'BEGIN{ printf("%.f\n",((memtotal*1024)*0.7)/(hpsize*1024)) }')

#MEMTOTAL/50%
SHMMAX=$(echo| awk -v memtotal="$MEMTOTAL"  'BEGIN{ printf("%.f\n",(memtotal*1024)*0.5) }')

##verifica se existe o parametro mais de uma vez no sysctl.conf
for i in $(seq 1 ${#SYSCTL[@]})
do
  if [ -z "${SYSCTL[$i]}" ]; then ##FAZ NVL PRA O VALOR NOTSET
    SYSCTL[$i]="NOTSET"
  fi
  COLUNA=$(echo ${SYSCTL[$i]} |awk '{ print NF }') #calcula quantos fields retornaram

  if [[ ( $i != "3"  &&  $i != "5"  ) && (  $COLUNA -gt "1" ) ]]; then ##se retornou mais de 1 e nao era esperado
    echo ${SYSCTL_PARAM[$i]}" "${SYSCTL[$i]}" <<ERROR: mais de um parametro encontrado no sysctl"
    let sumariza_erro++
  else #nao tem valor duplicado
    if [[ ( "$i" == "1"  ) && ("${SYSCTL[$i]}" -lt "$MIN_SHMALL" ||  "${SYSCTL[$i]}" -gt "$MAX_SHMALL" ) ]]; then #kernel.shmall
          VALUE_ERROR=" <<ERROR: valor deve estar entre $MIN_SHMALL e $MAX_SHMALL"
          let sumariza_erro++
    elif [[ ( "$i" == "2"  ) && ("${SYSCTL[$i]}" != "$SHMMAX" ) ]]; then #kernel.shmmax
          VALUE_ERROR=" <<ERROR: valor deve ser 50% da memoria em bytes $SHMMAX"
          let sumariza_erro++
    elif [[ ( "$i" == "3"  ) ]]; then #kernel.sem
          VALOR1=$(echo ${SYSCTL[$i]}|cut -d" " -f1 )
          VALOR2=$(echo ${SYSCTL[$i]}|cut -d" " -f2 )
          VALOR3=$(echo ${SYSCTL[$i]}|cut -d" " -f3 )
          VALOR4=$(echo ${SYSCTL[$i]}|cut -d" " -f4 )
          if [ "$VALOR1" != "250" ]; then
            VALUE_ERROR=" <<ERROR: valor deve ser 250 32000 100 128"
            let sumariza_erro++
          elif [ "$VALOR2" != "32000" ]; then
            VALUE_ERROR=" <<ERROR: valor deve ser 250 32000 100 128"
            let sumariza_erro++
          elif [ "$VALOR3" != "100" ]; then
            VALUE_ERROR=" <<ERROR: valor deve ser 250 32000 100 128"
            let sumariza_erro++
          elif [ "$VALOR4" != "128" ]; then
            VALUE_ERROR=" <<ERROR: valor deve ser 250 32000 100 128"
            let sumariza_erro++
          fi
    elif [[ ( "$i" == "4"  ) && ("${SYSCTL[$i]}" -lt "4096" ) ]]; then #kernel.shmmni
          VALUE_ERROR=" <<ERROR: valor deve ser maior igual a 4096"
          let sumariza_erro++
    elif [[ ( "$i" == "5"  ) ]]; then #net.ipv4.ip_local_port_range
          VALOR1=$(echo ${SYSCTL[$i]}|cut -d" " -f1 )
          VALOR2=$(echo ${SYSCTL[$i]}|cut -d" " -f2 )
          if [ "$VALOR1" != "9000" ]; then
            VALUE_ERROR=" <<ERROR: valor deve ser 9000 65500"
            let sumariza_erro++
          elif [ "$VALOR2" != "65500" ]; then
            VALUE_ERROR=" <<ERROR: valor deve ser 9000 65500"
            let sumariza_erro++
          fi   
    elif [[ ( "$i" == "6"  ) && ("${SYSCTL[$i]}" != "262144" ) ]]; then #net.core.rmem_default
          VALUE_ERROR=" <<ERROR: valor deve ser igual a 262144"
          let sumariza_erro++
    elif [[ ( "$i" == "7"  ) && ("${SYSCTL[$i]}" != "4194304" ) ]]; then #net.core.rmem_max
          VALUE_ERROR=" <<ERROR: valor deve ser igual a 4194304"
          let sumariza_erro++
    elif [[ ( "$i" == "8"  ) && ("${SYSCTL[$i]}" != "262144" ) ]]; then #net.core.wmem_default
          VALUE_ERROR=" <<ERROR: valor deve ser igual a 262144"
          let sumariza_erro++
    elif [[ ( "$i" == "9"  ) && ("${SYSCTL[$i]}" != "1048576" ) ]]; then #net.core.wmem_max
          VALUE_ERROR=" <<ERROR: valor deve ser igual a 1048576"
          let sumariza_erro++
    elif [[ ( "$i" == "10"  ) && ("${SYSCTL[$i]}" != "3145728" ) ]]; then #fs.aio-max-nr
          VALUE_ERROR=" <<ERROR: valor deve ser igual a 3145728"
          let sumariza_erro++
    elif [[ ( "$i" == "11"  ) && ("${SYSCTL[$i]}" != "6815744" ) ]]; then #fs.file-max
          VALUE_ERROR=" <<ERROR: valor deve ser igual a 6815744"
          let sumariza_erro++
    elif [[ ( "$i" == "12"  ) && ("${SYSCTL[$i]}" -lt "$MIN_NR_HUGEPAGES" ||  "${SYSCTL[$i]}" -gt "$MAX_NR_HUGEPAGES" ) ]]; then #vm.nr_hugepages
          VALUE_ERROR=" <<ERROR: valor deve estar entre $MIN_NR_HUGEPAGES e $MAX_NR_HUGEPAGES"
          let sumariza_erro++
    fi
    fn_printcol "${SYSCTL_PARAM[$i]}" "${SYSCTL[$i]} $VALUE_ERROR"
  fi
  #RESULTADO CSV
  fn_output_csv "$HOSTNAME" "OS" "SYSCTL" "${SYSCTL_PARAM[$i]}" "${SYSCTL[$i]}" ""
  unset VALUE_ERROR
done
#ENCONTROU ERRO
if [ $sumariza_erro -gt "0" ]; then
  fn_sumariza_erro "Erros encontrados ao verificar sysctl.conf"
fi;
sumariza_erro=0
#--FIM--

###################imprime subtitulo

fn_subtitulo "Coleta LIMITS.CONF"

LIMITS_VALUE[1]=$(cat /etc/security/limits.conf |grep -v "#"| grep "oracle" |grep -w "nproc" |grep "soft" |awk {' print $4'})
LIMITS_VALUE[2]=$(cat /etc/security/limits.conf |grep -v "#"| grep "oracle" |grep -w "nproc" |grep "hard" |awk {' print $4'})
LIMITS_VALUE[3]=$(cat /etc/security/limits.conf |grep -v "#"| grep "oracle" |grep -w "nofile" |grep "soft" |awk {' print $4'})
LIMITS_VALUE[4]=$(cat /etc/security/limits.conf |grep -v "#"| grep "oracle" |grep -w "nofile" |grep "hard" |awk {' print $4'})
LIMITS_VALUE[5]=$(cat /etc/security/limits.conf |grep -v "#"| grep "oracle" |grep -w "stack" |grep "soft" |awk {' print $4'})
LIMITS_VALUE[6]=$(cat /etc/security/limits.conf |grep -v "#"| grep "oracle" |grep -w "stack" |grep "hard" |awk {' print $4'})
LIMITS_VALUE[7]=$(cat /etc/security/limits.conf |grep -v "#"| grep "oracle" |grep -w "memlock" |grep "soft" |awk {' print $4'})
LIMITS_VALUE[8]=$(cat /etc/security/limits.conf |grep -v "#"| grep "oracle" |grep -w "memlock" |grep "hard" |awk {' print $4'})
MEMLOCK=$(awk -v MEMTOTAL="${MEMTOTAL}" 'BEGIN{ printf ("%.f\n",((MEMTOTAL)*0.9) )}')

LIMITS_PARAM[1]="oracle soft nproc"
LIMITS_PARAM[2]="oracle hard nproc"
LIMITS_PARAM[3]="oracle soft nofile" 
LIMITS_PARAM[4]="oracle hard nofile" 
LIMITS_PARAM[5]="oracle soft stack"
LIMITS_PARAM[6]="oracle hard stack"
LIMITS_PARAM[7]="oracle soft memlock"
LIMITS_PARAM[8]="oracle hard memlock"

for i in $(seq 1 ${#LIMITS_VALUE[@]})
do
  COLUNA=$(echo ${LIMITS_VALUE[$i]} |awk '{ print NF }') #calcula quantos fields retornaram
  if [  $COLUNA -gt "1" ]; then ##se retornou mais de 1 e nao era esperado
    echo ${LIMITS_PARAM[$i]}" "${LIMITS_VALUE[$i]}" <<ERROR: mais de um parametro encontrado no limits.conf"
    let sumariza_erro++
  else #nao tem valor duplicado
    if [ -z ${LIMITS_VALUE[$i]} ]; then
      LIMITS_VALUE[$i]=0
    fi
    if [ "$i" == "1" ] && [ "${LIMITS_VALUE[$i]}" -lt "16384" ]; then
      VALUE_ERROR=" <<ERROR: valor menor que 16384"
      let sumariza_erro++ 
    elif [ "$i" == "2" ] && [ "${LIMITS_VALUE[$i]}" -lt "16384" ]; then
      VALUE_ERROR=" <<ERROR: valor menor que 16384"
      let sumariza_erro++

    elif [ "$i" == "3" ] && [ "${LIMITS_VALUE[$i]}" -lt "65536" ]; then
      VALUE_ERROR=" <<ERROR: valor menor que 65536"
      let sumariza_erro++

    elif [ "$i" == "4" ] && [ "${LIMITS_VALUE[$i]}" -lt "65536" ]; then
      VALUE_ERROR=" <<ERROR: valor menor que 65536"
      let sumariza_erro++

    elif [ "$i" == "5" ] && [ "${LIMITS_VALUE[$i]}" -lt "10240" ]; then
      VALUE_ERROR=" <<ERROR: valor menor que 10240"
      let sumariza_erro++

    elif [ "$i" == "6" ] && [ "${LIMITS_VALUE[$i]}" -lt "10240" ]; then
      VALUE_ERROR=" <<ERROR: valor menor que 10240"
      let sumariza_erro++   

    elif [ "$i" == "7" ] && [ "${LIMITS_VALUE[$i]}" -lt "$MEMLOCK" ]; then
      VALUE_ERROR=" <<ERROR: valor menor que $MEMLOCK"
      let sumariza_erro++
    
    elif [ "$i" == "8" ] && [ "${LIMITS_VALUE[$i]}" -lt "$MEMLOCK" ]; then
      VALUE_ERROR=" <<ERROR: valor menor que $MEMLOCK"
      let sumariza_erro++
    fi    
  fn_printcol "${LIMITS_PARAM[$i]}" "${LIMITS_VALUE[$i]}" "$VALUE_ERROR" 
  unset VALUE_ERROR
  fi
done

user_count=0
for i in $(cat /etc/security/limits.conf | egrep "oracle|oemagent|[*]" | grep -v "#" | awk {' print $1 '} |sed "s/\*\**/all/g")
do
  #LIMIT_USER=$(echo $i| cut -d"|" -f1)
  #Verifica se existe usuario * depois do oracle ou oemagent
  if [ "$i" == "oracle" ] || [ "$i" == "oemagent" ]; then
    let user_count++
  fi
  if [ "$i" == "all" ] && [ $user_count -gt "0" ]; then
    USER_CHECK="ERROR: Encontrado configuracao para usuario '*' após usuario oracle ou oemagent"
    let sumariza_erro++
  fi
done

if [ $sumariza_erro == "0" ]; then
  echo -e "\nSUCCESS: Coletado dados de limits.conf"
else
  #ENCONTROU ERRO
  if [ ! -z "$USER_CHECK" ]; then echo -e "\n$USER_CHECK"; fi;
  fn_sumariza_erro "Existem erros na configuracao de limits.conf"
fi;
sumariza_erro=0
#--FIM--

##Se a versao de SO for maior que 6
if [ "$OS_VERSION" -gt "6" ]; then
  ###################imprime subtitulo
  fn_subtitulo "Coleta LOGIND.CONF"
  LOGIND=$(cat /etc/systemd/logind.conf | grep -i RemoveIPC)

  ###################imprime subtitulo
  fn_subtitulo "Coleta TMP.CONF"
  if [ -z $(cat /usr/lib/tmpfiles.d/tmp.conf | egrep "/var/tmp/.oracle|/tmp/.oracle|/usr/tmp/.oracle") ]; then
    echo 'NOTSET'
  else
    cat /usr/lib/tmpfiles.d/tmp.conf | egrep "/var/tmp/.oracle|/tmp/.oracle|/usr/tmp/.oracle"
  fi
fi

###################imprime subtitulo
fn_subtitulo "Coleta dados de NICs(PUB, PRIV e BKP)"

##IDENTIFICA AS INTERFACES PRIVADA e PUBLICA
if [ $RAC_FOUND -gt "0" ]; then ##TEM RAC
  #PUBLIC
  count=0
  for i in $($GRID_HOME/bin/oifcfg getif | grep -i public | awk {' print $1 '}) ##MAIS DE UMA INTERFACE CONFIGURADA
  do
    let count++
    PUBETH["$count"]="$i"
    if [ ${PUBETH[$count]} != "bond0" ]; then
      let sumariza_erro++
      MSG_ERRO="ERROR: Esperado nome bond0"
    elif [ $RAC_FOUND == "0" ] && [ ${PUBETH[$count]} != "eth0" ]; then
      let sumariza_erro++
      MSG_ERRO="ERROR: Esperado nome eth0"
    else
      MSG_ERRO="SUCCESS"
    fi
    fn_printcol "PUBLIC NIC" "${PUBETH[$count]} $MSG_ERRO" 
    #RESULTADO CSV
    fn_output_csv "$HOSTNAME" "OS" "NETWORK" "PUBETH" "${PUBETH[$count]}"
  unset MSG_ERRO
  done
  ##PRIVATE
  count=0
  for i in $($GRID_HOME/bin/oifcfg getif | grep -i cluster_interconnect | awk {' print $1 '}) ##MAIS DE UMA INTERFACE CONFIGURADA
  do
    let count++
    PRIVETH["$count"]="$i"
    if [ "${PRIVETH[$count]}" != "bond2" ]; then
      let sumariza_erro++
      MSG_ERRO="ERROR: Esperado nome bond2"
    else
      MSG_ERRO="SUCCESS"
    fi
    fn_printcol "PRIVATE NIC" "${PRIVETH[$count]} $MSG_ERRO" 
    #RESULTADO CSV
    fn_output_csv "$HOSTNAME" "OS" "NETWORK" "PRIVETH" "${PRIVETH[$count]}"
  unset MSG_ERRO
  done
  #BACKUP
  BKP_VIP=$($GRID_HOME/bin/crsctl status resource -t |egrep -i "bkp|backup")
  ACTIVE_NODE=$($GRID_HOME/bin/crsctl status res $BKP_VIP |grep STATE |awk '{ print $3 }')
  BKPETH[1]=$(ip -o -4 addr show | grep  $($GRID_HOME/bin/crsctl status res $BKP_VIP -p |grep -iw USR_ORA_VIP |sed -n "s/=/ /p" |awk '{ print $2 }' | cut -d"." -f1-3) | head -1 |awk {' print $2'})
  if [ -z $BKP_VIP ]; then
    echo -e "\nERROR: Nao foi possivel detectar nenhum VIP nesse cluster"
    let sumariza_erro++
  else
    if [ ${BKPETH[1]} != "bond1" ]; then
      let sumariza_erro++
      MSG_ERRO="ERROR: Esperado nome bond1"
    else
      MSG_ERRO="SUCCESS"
    fi
    fn_printcol "BACKUP NIC" "${BKPETH[1]} $MSG_ERRO" 
    echo -e "\nWARNING: VIP de backup ativo no node $ACTIVE_NODE"
  fi
  unset MSG_ERRO
  #ENCONTROU ERRO
  if [ $sumariza_erro -gt "0" ]; then
    fn_sumariza_erro "Interfaces de rede fora do padrao"
  fi;
  sumariza_erro=0

  
else ##NAO TEM RAC ou NODE DOWN
  PUBETH[1]=$(ip -o -4 addr show | grep  $(ping $HOSTNAME -c 1 |head -1|awk {' print $3 '} |sed -n "s/(//pg" |sed -n "s/)//pg") | awk {' print $2'})
  if [ -z ${PUBETH[1]} ]; then #NAO FOI ENCONTRADA NENHUMA INTERFACE
    let sumariza_erro++
    MSG_ERRO="ERROR: Nenhuma interface reconhecida"
  else
      MSG_ERRO="SUCCESS"
  fi
  fn_printcol "PUBLIC NIC" "${PUBETH[1]} $MSG_ERRO" 
  fn_printcol "PRIVATE NIC" "NOTSET"
  fn_printcol "BACKUP NIC" "NOTSET" 
  echo -e "\nWARNING: Nao foi detectado nenhum CRS no servidor $HOSTNAME"
  echo
  fn_output_csv "$HOSTNAME" "OS" "NETWORK" "PUBETH" "${PUBETH[1]}"
  fn_output_csv "$HOSTNAME" "OS" "NETWORK" "PRIVETH" "NOTSET"
  fn_output_csv "$HOSTNAME" "OS" "NETWORK" "BKPETH" "NOTSET"
  unset MSG_ERRO
  #ENCONTROU ERRO
  if [ $sumariza_erro -gt "0" ]; then
    fn_sumariza_erro "Nao foi possivel detectar interfaces de rede"
  fi;
  sumariza_erro=0
fi

###################imprime subtitulo
fn_subtitulo "Verifica LACP"

if [ $RAC_FOUND -gt "0" ]; then ##Verifica LACP somente para RAC
  for i in $(seq 1 ${#PUBETH[@]}) #Percorre as interfaces publicas encontradas
  do
    if [ ! -f "/proc/net/bonding/${PUBETH[$i]}" ]; then #interface publica
      fn_printcol "PUBLIC NIC" "${PUBETH[$i]}" "ERROR: LACP inativo" 
      let sumariza_erro++
      #RESULTADO CSV
      fn_output_csv "$HOSTNAME" "OS" "NETWORK" "PUBETH_LACP" "NOTFOUND"
    else
      fn_printcol "PUBLIC NIC" "${PUBETH[$i]}" "SUCCESS" 
      for i in $(cat /proc/net/bonding/${PUBETH[$i]} |grep -i "Slave Interface"|awk {' print $3'})
      do
        fn_printcol "SLAVE INTERFACE" "$i" 
      done
      #RESULTADO CSV
      fn_output_csv "$HOSTNAME" "OS" "NETWORK" "PUBETH_LACP" "1"
    fi
  done
  echo
  for i in $(seq 1 ${#PRIVETH[@]}) #Percorre as interfaces privadas encontradas
  do
    if [ ! -f "/proc/net/bonding/${PRIVETH[$i]}" ]; then #interface privada
      fn_printcol "PRIVATE NIC" "${PRIVETH[$i]}" "ERROR: LACP inativo" 
      let sumariza_erro++
      #RESULTADO CSV
      fn_output_csv "$HOSTNAME" "OS" "NETWORK" "PRIVETH_LACP" "NOTSET"
    else
      fn_printcol "PRIVATE NIC" "${PRIVETH[$i]}" "SUCCESS" 
      for i in $(cat /proc/net/bonding/${PRIVETH[$i]} |grep -i "Slave Interface"|awk {' print $3'})
      do
        fn_printcol "SLAVE INTERFACE" "$i" 
      done
      #RESULTADO CSV
      fn_output_csv "$HOSTNAME" "OS" "NETWORK" "PRIVETH_LACP" "1"
    fi
  done
  echo
  for i in $(seq 1 ${#BKPETH[@]}) #Percorre as interfaces backup encontradas
  do
    if [ ! -f "/proc/net/bonding/${BKPETH[$i]}" ]; then #interface publica
      fn_printcol "BACKUP NIC" "${BKPETH[$i]}" "ERROR: LACP inativo" 
      let sumariza_erro++
      #RESULTADO CSV
      fn_output_csv "$HOSTNAME" "OS" "NETWORK" "BKPETH_LACP" "NOTSET"
      
    else
      fn_printcol "BACKUP NIC" "${BKPETH[$i]}" "SUCCESS" 
      for i in $(cat /proc/net/bonding/${BKPETH[$i]} |grep -i "Slave Interface"|awk {' print $3'})
      do
        fn_printcol "SLAVE INTERFACE" "$i" 
      done
      #RESULTADO CSV
      fn_output_csv "$HOSTNAME" "OS" "NETWORK" "BKPETH_LACP" "1"
    fi
  done
else
  echo -e "\nWARNING: Ambiente nao necessita de LACP ou CRS está baixado"
  #RESULTADO CSV
  fn_output_csv "$HOSTNAME" "OS" "NETWORK" "PUBETH_LACP" "NOTSET"
fi

#ENCONTROU ERRO
if [ $sumariza_erro -gt "0" ]; then
  fn_sumariza_erro "Configuracao de LACP incorreta"
fi;
sumariza_erro=0

###################imprime subtitulo
fn_subtitulo "Verifica velocidade das NICs"

  for i in $(seq 1 ${#PUBETH[@]}) #Percorre as interfaces publicas encontradas
  do
    if [ ! -f "/sys/class/net/${PUBETH[$i]}/speed" ]; then #interface publica
      fn_printcol "PUBLIC NIC" "${PUBETH[$i]}" "ERROR: Nao foi possivel detectar velocidade" 
      let sumariza_erro++
      #RESULTADO CSV
      fn_output_csv "$HOSTNAME" "OS" "NETWORK" "PUBETH_SPEED" "0"
    else
      PUBSPEED=$(cat /sys/class/net/${PUBETH[$i]}/speed)
      if [ $PUBSPEED -lt "10000" ]; then
          let sumariza_erro++
          MSG_ERRO="ERROR: Velocidade menor que 10 gigabit"
      else
        MSG_ERRO="SUCCESS"
      fi
      fn_printcol "PUBLIC NIC" "${PUBETH[$i]}"
      fn_printcol "PUBLIC NIC SPEED" "$PUBSPEED $MSG_ERRO" 
      #RESULTADO CSV
      fn_output_csv "$HOSTNAME" "OS" "NETWORK" "PUBETH_SPEED" "$PUBSPEED"
    fi
  unset MSG_ERRO
  done
  echo
##PRIVATE  
  if [ ${#PRIVETH[@]} -gt "0" ]; then ##Encontrou interface privada
    for i in $(seq 1 ${#PRIVETH[@]}) #Percorre as interfaces PRIVADA encontradas
    do
      if [ ! -f "/sys/class/net/${PRIVETH[$i]}/speed" ]; then #interface privada
        fn_printcol "PRIVATE NIC" "${PRIVETH[$i]}" "ERROR: Nao foi possivel detectar velocidade" 
        let sumariza_erro++
        #RESULTADO CSV
        fn_output_csv "$HOSTNAME" "OS" "NETWORK" "PRIVETH_SPEED" "0"
      else
        PRIVSPEED=$(cat /sys/class/net/${PRIVETH[$i]}/speed 2>/dev/null)
        if [ "$?" -gt "0" ]; then
          let sumariza_erro++
          MSG_ERRO="ERROR: Impossivel detectar velocidade"
        elif [ "$PRIVSPEED" -lt "10000" ]; then
          let sumariza_erro++
          MSG_ERRO="ERROR: Velocidade menor que 10 gigabit"
        else
          MSG_ERRO="SUCCESS"
        fi
        fn_printcol "PRIVATE NIC" "${PRIVETH[$i]}"
        fn_printcol "PRIVATE NIC SPEED" "$PRIVSPEED $MSG_ERRO" 
        #RESULTADO CSV
        fn_output_csv "$HOSTNAME" "OS" "NETWORK" "PRIVETH_SPEED" "$PRIVSPEED"
      fi
    unset MSG_ERRO  
    done
  echo
  fi
  
##BACKUP
  if [ ${#BKPETH[@]} -gt "0" ]; then ##Encontrou interface backup
    for i in $(seq 1 ${#BKPETH[@]}) #Percorre as interfaces backup encontradas
    do
      if [ ! -f "/sys/class/net/${BKPETH[$i]}/speed" ]; then #interface backup
        fn_printcol "BACKUP NIC" "${BKPETH[$i]}" "ERROR: Nao foi possivel detectar velocidade" 
        let sumariza_erro++
        #RESULTADO CSV
        fn_output_csv "$HOSTNAME" "OS" "NETWORK" "BKPETH_SPEED" "0"
      else
        BKPSPEED=$(cat /sys/class/net/${BKPETH[$i]}/speed)
        if [ "$BKPSPEED" -lt "10000" ]; then
          let sumariza_erro++
          MSG_ERRO="ERROR: Velocidade menor que 10 gigabit"
        else
          MSG_ERRO="SUCCESS"
        fi
        fn_printcol "BACKUP NIC" "${BKPETH[$i]}"
        fn_printcol "BACKUP NIC SPEED" "$BKPSPEED $MSG_ERRO" 
        #RESULTADO CSV
        fn_output_csv "$HOSTNAME" "OS" "NETWORK" "BKPETH_SPEED" "$BKPSPEED"
      fi
    unset MSG_ERRO  
    done
  fi

#ENCONTROU ERRO
if [ $sumariza_erro -gt "0" ]; then
  fn_sumariza_erro "Velocidade de interfaces fora do recomendado"
fi;
sumariza_erro=0

###################imprime subtitulo
fn_subtitulo "Verifica MTU das NICs"

  for i in $(seq 1 ${#PUBETH[@]}) #Percorre as interfaces publicas encontradas
  do
    if [ ! -f "/sys/class/net/${PUBETH[$i]}/mtu" ]; then #interface publica
      fn_printcol "PUBLIC NIC" "${PUBETH[$i]}" "ERROR: Nao foi possivel detectar MTU" 
      let sumariza_erro++
      #RESULTADO CSV
      fn_output_csv "$HOSTNAME" "OS" "NETWORK" "PUBETH_MTU" "0"
    else
      PUBMTU=$(cat /sys/class/net/${PUBETH[$i]}/mtu)
      if [ "$PUBMTU" == "1500" ] || [ $PUBMTU == "9000" ]; then
          MSG_ERRO="SUCCESS" 
      else
        let sumariza_erro++
          MSG_ERRO="ERROR: MTU fora do padrao"
      fi
      fn_printcol "PUBLIC NIC" "${PUBETH[$i]}"
      fn_printcol "PUBLIC NIC SPEED" "$PUBMTU" "$MSG_ERRO"
      #RESULTADO CSV
      fn_output_csv "$HOSTNAME" "OS" "NETWORK" "PUBETH_MTU" $PUBMTU
    fi
  done
  if [ ${#PRIVETH[@]} -gt "0" ]; then ##Encontrou interface privada
    for i in $(seq 1 ${#PRIVETH[@]}) #Percorre as interfaces PRIVADA encontradas
    do
      if [ ! -f "/sys/class/net/${PRIVETH[$i]}/mtu" ]; then #interface privada
        fn_printcol "PRIVATE NIC" "${PRIVETH[$i]}" "ERROR: Nao foi possivel detectar MTU" 
        let sumariza_erro++
        #RESULTADO CSV
        fn_output_csv "$HOSTNAME" "OS" "NETWORK" "PRIVETH_MTU" "0"
      else
        PRIVMTU=$(cat /sys/class/net/${PRIVETH[$i]}/mtu)
        if [ "$PRIVMTU" == "9000" ]; then
          MSG_ERRO="SUCCESS" 
        else
          let sumariza_erro++
          MSG_ERRO="ERROR: MTU fora do padrao 9000"
        fi
        fn_printcol "PRIVATE NIC" "${PRIVETH[$i]}"
        fn_printcol "PRIVATE NIC SPEED" "$PRIVMTU" "$MSG_ERRO"
        #RESULTADO CSV
        fn_output_csv "$HOSTNAME" "OS" "NETWORK" "PRIVETH_MTU" $PRIVMTU
      fi
    done
    
  fi
#ENCONTROU ERRO
if [ $sumariza_erro -gt "0" ]; then
  fn_sumariza_erro "Problemas na configuracao de MTU das NICs"
fi;
sumariza_erro=0


###################imprime subtitulo

fn_subtitulo "Verifica uso do multipath"
echo "*A coleta pode demorar alguns minutos"
echo 
for i in $(ps -ef | grep pmon |grep ASM | egrep -v "grep|APX|MGMTDB" | awk {' print substr($8,10) '}); do
ORACLE_SID=$i
ORAENV_ASK=NO
. oraenv 1>/dev/null <<EOF
$ORACLE_SID
EOF
sqlplus -s / as sysdba <<EOF >.hcdb_multipath
set head off
set timi off
set time off
SELECT distinct
  CASE substr(path,1,instr(path,'sddlm',1)+4) --PROCURANDO HDS
    WHEN '/dev/sddlm' THEN 'HDDLM'
    ELSE CASE substr(path,1,instr(path,'emcpower',1)+7) --PROCURANDO EMCPOWER
	     WHEN '/dev/emcpower' then 'Powerpath'
		 ELSE CASE substr(path,1,instr(path,'dm',1)+1) --PROCURANDO MULTIPATH
	          WHEN '/dev/dm' then 'Nativo'
		      ELSE CASE substr(path,1,instr(path,'oracleasm',1)+8) --PROCURANDO ASMLIB
			       WHEN '/dev/oracleasm' then 'Asmlib'
		           ELSE CASE substr(path,1,instr(path,'ORCL:',1)+5) --PROCURANDO ASMLIB
			            WHEN 'ORCL:D' then 'Asmlib'
		                ELSE CASE substr(path,1,instr(path,'ORCL:',1)+4) --PROCURANDO ASMLIB
			                 WHEN 'DISK_' then 'Asmlib'
		                     ELSE CASE substr(path,1,instr(path,'ORCL:',1)+3) --PROCURANDO ASMLIB
			                      WHEN 'DSK_' then 'Asmlib'
		                          ELSE 'Desconhecido'
								  END
							END
						END
		           END
		      END
		 END
  END
FROM v\$asm_disk;
EOF
MULTIPATH=$(cat .hcdb_multipath|tr -d '\n')
if [ $MULTIPATH == "Desconhecido" ]; then
  ASMLIB=$(/etc/init.d/oracleasm status 2>/dev/null)
  if [ $? = 0 ]; then
	  echo -e "\nERROR: ASMLIB Encontrado mas nao foi possivel determinar o multipath" 
  else
    echo -e "\nERROR: Nao foi possivel determinar o multipath utilizado"
    fn_sumariza_erro "Nao foi possivel determinar o multipath utilizado"
  fi
elif [ $MULTIPATH == "Asmlib" ]; then 
  echo -e "ASMLIB encontrado no servidor "$HOSTNAME"\n"
  /etc/init.d/oracleasm querydisk -d $(/etc/init.d/oracleasm listdisks) | cut -f2,10,11 -d" " | perl -pe 's/"(.*)".*\[(.*), *(.*)\]/$1 $2 $3/g;' | while read v_asmdisk v_minor v_major
  do
    DEVICE=$(ls -l /dev | grep " $v_minor, *$v_major " | awk '{print "/"$10}')
    if [[ "$DEVICE" =~ "/sddlm" ]]; then
      echo "HDDLM"
    elif [[ "$DEVICE" =~ "/emcpower" ]]; then
      echo "Powerpath"
    elif [[ "$DEVICE" =~ "/dm" ]]; then
      echo "Nativo"
	  elif [[ "$DEVICE" =~ "/sd" ]]; then
      echo "DISCO_SD"
    else 
      echo "Outro"
    fi
  done |sort -u > .hcdb_device  #armazena resultado unico em arquivo temporario
  #MULTIPATH=$(cat .hcdb_device)
  for MULTIPATH in $(cat .hcdb_device)
  do
  if [ "$MULTIPATH" == "Nativo" ]; then
    fn_printcol "Multipath Utizado" "$MULTIPATH"
    #echo "Multipath Utizado......: "$MULTIPATH
    #echo -e "\nSUCCESS: Multipath nativo em uso pelo ASMLIB"
    #fn_output_csv "$HOSTNAME" "OS" "MULTIPATH" $MULTIPATH "1"
  else 
    fn_printcol "Multipath Utizado" "$MULTIPATH"
    let sumariza_erro++
    #echo -e "\nERROR: Multipath nativo NaO usado pelo ASMLIB"
    #fn_output_csv "$HOSTNAME" "OS" "MULTIPATH" $MULTIPATH "0"
    #fn_sumariza_erro "Multipath nativo NaO usado pelo ASMLIB"
  fi
  done;
  #ENCONTROU ERRO
  if [ "$sumariza_erro" -gt "0" ]; then
  echo -e "\nERROR: Multipath nativo NaO usado pelo ASMLIB"
    fn_sumariza_erro "Multipath nativo NaO usado pelo ASMLIB"
    fn_output_csv "$HOSTNAME" "OS" "MULTIPATH" $MULTIPATH "1"
  else 
    echo -e "\nSUCCESS: Multipath nativo em uso pelo ASMLIB"
    fn_output_csv "$HOSTNAME" "OS" "MULTIPATH" $MULTIPATH "0"
  fi;
  sumariza_erro=0
  
  ###################imprime subtitulo
  fn_subtitulo "Verifica configuracao do ASMLIB"

  #Verifica configuracao do asmlib
  ORACLEASM[1]='ORACLEASM_ENABLED=true'
  ORACLEASM[2]='ORACLEASM_UID=oracle'
  ORACLEASM[3]='ORACLEASM_GID=dba'
  ORACLEASM[4]='ORACLEASM_SCANBOOT=true'
  ORACLEASM[5]='ORACLEASM_SCANORDER="dm"'
  ORACLEASM[6]='ORACLEASM_SCANEXCLUDE="sd"'
  ORACLEASM[7]='ORACLEASM_USE_LOGICAL_BLOCK_SIZE=false'
  for i in $(cat /etc/sysconfig/oracleasm |egrep "ORACLEASM_ENABLED|ORACLEASM_UID|ORACLEASM_GID|ORACLEASM_SCANBOOT|ORACLEASM_SCANORDER|ORACLEASM_SCANEXCLUDE|ORACLEASM_USE_LOGICAL_BLOCK_SIZE" |grep -v "#" )
  do
    PARAMETRO_ATUAL=$(echo $i|cut -d"=" -f1 )
    VALOR_ATUAL=$(echo $i|cut -d"=" -f2 )
    #echo -e "\nPARAMETRO_ATUAL="$PARAMETRO_ATUAL" VALOR_ATUAL="$VALOR_ATUAL" i="$i
    #read -p "Aperte"
    for j in $(seq 1 ${#ORACLEASM[@]})
    do
      PARAMETRO=$(echo ${ORACLEASM[$j]} |cut -d"=" -f1 )
      VALOR=$(echo ${ORACLEASM[$j]} |cut -d"=" -f2 )
      #echo -e "\nPARAMETRO="$PARAMETRO" VALOR="$VALOR
      #read -p "Aperte"
      if [[ "$PARAMETRO" == "$PARAMETRO_ATUAL" ]]; then
        if [[ "$VALOR_ATUAL" != "$VALOR" ]]; then
          echo -e "\nERROR   -> "$PARAMETRO_ATUAL"="$VALOR_ATUAL
          echo "CORRETO -> "$PARAMETRO"="$VALOR
          echo
          let sumariza_erro++
        else
          echo "SUCCESS -> "$PARAMETRO_ATUAL"="$VALOR_ATUAL
        fi
      fi
    done
  done
  #ENCONTROU ERRO
  if [ $sumariza_erro -gt "0" ]; then
    fn_sumariza_erro "Problemas encontrados na configuracao do ASMLIB"
  fi;
  sumariza_erro=0
elif [ $MULTIPATH == "Nativo" ]; then #Tem multipath nativo mas nao tem ASMLIB
  fn_printcol "Multipath Utizado" "$MULTIPATH"
  #echo "Multipath Utizado......: "$MULTIPATH
  echo -e "\nWARNING: ASMLIB nao foi encontrado no servidor"
  echo -e "\nSUCCESS: Multipath nativo em uso pelo ASM"
  fn_output_csv "$HOSTNAME" "OS" "MULTIPATH" $MULTIPATH "1"
else #Nao tem multipath nativo nem ASMLIB
  fn_printcol "Multipath Utizado" "$MULTIPATH"
  #echo "Multipath Utizado......: "$MULTIPATH
  echo -e "\nERROR: Multipath nativo NaO usado pelo ASM"
  fn_output_csv "$HOSTNAME" "OS" "MULTIPATH" $MULTIPATH "0"
  fn_sumariza_erro "Multipath nativo NaO usado pelo ASMLIB"
fi


###################imprime subtitulo
fn_subtitulo "Verifica parametros do ASM"

sqlplus -s / as sysdba <<EOF > .hcdb_asmparameters_$ORACLE_SID
set lines 200
set pages 500
col name for a60
col value for a120
set head off
set timi off
set time off
select name,upper(value) value from v\$parameter order by 1;
EOF
#Exibe parametros
#$(grep -i "GREPDISPLAY>" .hcdb_asmparams |awk {' print $2" "$3'})##PAREI AQUi, precisa ver um jeito melhor para mostrar os parametros e depois salva-los no csv

##CONFIG
echo "processes|-ge|200">>.hcdb_asmparamref
echo "memory_max_target|-ge|1610612736">>.hcdb_asmparamref
echo "memory_target|-ge|1610612736">>.hcdb_asmparamref
#echo "sga_max_size|==|0">>.hcdb_asmparamref
#echo "sga_target|==|0">>.hcdb_asmparamref
echo "asm_diskstring|==|/DEV/ORACLEASM/DISKS/*">>.hcdb_asmparamref

  for hcdb_asmparameters in $(ls .hcdb_asmparameters_$ORACLE_SID)
  do
    printf "%- 10s %- 40s%-20s %s\n" "DBNAME" "PARAMETRO" "VALOR ATUAL" "STATUS"
    printf "%- 10s %- 40s%-20s %s\n" "----------" "---------------------------------------" "--------------------" "--------------"
    for parameter_row in $(cat .hcdb_asmparamref)
    do
      #VALORES DE REFERENCIA
      REF_VALUE=$(echo $parameter_row |cut -d"|" -f3)
      REF_CONDI=$(echo $parameter_row |cut -d"|" -f2)
      REF_PARAM=$(echo $parameter_row |cut -d"|" -f1)
      #VALORES ATUAIS
      CURRENT_VALUE=$(grep -i -w $REF_PARAM $hcdb_asmparameters |awk {'print $2'})
      CURRENT_NAME=$(grep -i -w $REF_PARAM $hcdb_asmparameters |awk {'print $1'})
      ASM=$(echo $hcdb_asmparameters |cut -f 3 -d '_')
      if [ -z "$CURRENT_VALUE" ]; then
        CURRENT_VALUE='NOTSET'
      fi
      CHECKING=$(echo "[[ " \"$CURRENT_VALUE\"\ "$REF_CONDI" \"$REF_VALUE\"\ " ]]")
      if eval $CHECKING ; then
        VALUE_ERROR="SUCCESS"
      else
        VALUE_ERROR="ERROR: $REF_CONDI $REF_VALUE"
        let sumariza_erro++
      fi
      #read -p "ENTER"
      printf "%- 10s %- 40s%-25s %s\n" "$ASM" "$REF_PARAM" "$CURRENT_VALUE" "$VALUE_ERROR"
    done
   echo
  done;
#ENCONTROU ERRO
if [ $sumariza_erro -gt "0" ]; then
  fn_sumariza_erro "Erros encontrados ao verificar parametros de $ORACLE_SID"
fi;
sumariza_erro=0
done

#Remove arquivo temporario
#$(rm .hcdb_* 2>/dev/null)

#KPIs
CPU_OVERALLOCATION=$(echo| awk -v soma_cpu="${SOMA_CPU}" -v total_cpu="${cpu_count}" 'BEGIN{ printf("%10.2f%\n",( (soma_cpu/total_cpu)*100 )) }')
MEMORY_USED=$(echo| awk -v memtotal="${MEMTOTAL}" -v memfree="${MEMFREE}" 'BEGIN{ printf("%10.2f%",( ((memtotal-memfree)/memtotal)*100 )) }')
HUGEPAGES_OVER_TOTAL_MEMORY=$(echo| awk -v memtotal="${MEMTOTAL}" -v hpsize="${HPSIZE}" -v hptotal="${HPTOTAL}" 'BEGIN{ printf("%10.2f%\n",( ( (hptotal*hpsize)/memtotal )*100 )) }')
SGA_OVER_TOTAL_HUGEPAGES=$(echo| awk -v sga="${SOMA_SGA}" -v hpsize="${HPSIZE}" -v hptotal="${HPTOTAL}" 'BEGIN{ printf("%10.2f%\n",( ( (sga/1024)/(hptotal*hpsize) )*100 ) ) }')
SWAP_USED=$(echo| awk -v swapused="${SWAPTOTAL}" -v swapfree="${SWAPFREE}" 'BEGIN{ printf("%10.2f%\n",( ((swapused-swapused)/swapused)*100 )) }')
PGASGA_OVER_TOTAL_MEMORY=$(echo| awk -v sga="${SOMA_SGA}" -v pga="${SOMA_PGA}" -v memtotal="${MEMTOTAL}" 'BEGIN{ printf("%10.2f%\n",( ((sga+pga)/(memtotal*1024))*100 ) ) }')
PGA_OVER_SGA=$(echo| awk -v sga="${SOMA_SGA}" -v pga="${SOMA_PGA}" 'BEGIN{ printf("%10.2f%\n",( ( pga/sga )*100 ) ) }')
GCS_OVER_CPU=$(echo| awk -v gcs="${SOMA_GCS}" -v total_cpu="${cpu_count}" 'BEGIN{ printf("%10.2f%\n",( ( gcs/total_cpu )*100 ) ) }')
PROCESS_OVER_LIMIT=$(echo| awk -v process="${SOMA_PROCESSES}" -v limit="${LIMITS_VALUE[2]}" 'BEGIN{ printf("%10.2f%\n",( ( process/limit )*100 ) ) }')
#SOMA_SGA/KERNEL.SHMALL
echo
echo "------------------------------------------------------------------------------------------"
echo "|                                       SUMMARY e KPIs                                   |"
echo "------------------------------------------------------------------------------------------"
printf "| %-30s %-10s || %-30s %-10s%s |\n" "CPUs TOTAL" $cpu_count "%Cpu_count Overallocation" $CPU_OVERALLOCATION
printf "| %-30s %-10s || %-30s %-10s%s |\n" "SUM of CPU_COUNT" $SOMA_CPU "%Memory Used" $MEMORY_USED
printf "| %-30s %-10s || %-30s %-10s%s |\n" "Total Memory(GB)" $(echo| awk -v var="${MEMTOTAL}" 'BEGIN{ printf("%10.2fGB\n",(var/1024/1024)) }') "%HugePages over Total Memory" $HUGEPAGES_OVER_TOTAL_MEMORY
printf "| %-30s %-10s || %-30s %-10s%s |\n" "Free Memory(GB)" $(echo| awk -v var="${MEMFREE}" 'BEGIN{ printf("%10.2fGB\n",(var/1024/1024)) }') "%SGA over HugePages" $SGA_OVER_TOTAL_HUGEPAGES
printf "| %-30s %-10s || %-30s %-10s%s |\n" "SUM of HugePages(GB)" $(echo| awk -v hpsize="${HPSIZE}" -v hptotal="${HPTOTAL}" 'BEGIN{ printf("%10.2fGB\n", (hptotal*hpsize)/1024/1024 ) }') "%Swap used" $SWAP_USED
printf "| %-30s %-10s || %-30s %-10s%s |\n" "SWAP Total(GB)" $(echo| awk -v var="${SWAPTOTAL}" 'BEGIN{ printf("%10.2fGB\n",(var/1024/1024)) }') "%PGA+SGA over Total Memory" $PGASGA_OVER_TOTAL_MEMORY
printf "| %-30s %-10s || %-30s %-10s%s |\n" "SWAP Free(GB)" $(echo| awk -v var="${SWAPFREE}" 'BEGIN{ printf("%10.2fGB\n",(var/1024/1024)) }') "%PGA over SGA" $PGA_OVER_SGA
printf "| %-30s %-10s || %-30s %-10s%s |\n" "SUM of SGA(GB)" $(echo| awk -v var="${SOMA_SGA}" 'BEGIN{ printf("%10.2fGB\n",(var/1024/1024/1024)) }') "%GCS over CPU TOTAL" $GCS_OVER_CPU
printf "| %-30s %-10s || %-30s %-10s%s |\n" "SUM of PGA(GB)" $(echo| awk -v var="${SOMA_PGA}" 'BEGIN{ printf("%10.2fGB\n",(var/1024/1024/1024)) }') "%Processes over OS user limit" $PROCESS_OVER_LIMIT
printf "| %-30s %-10s || %-30s %-10s%s |\n" "SUM of parallell_max_servers" $SOMA_PARALLEL_MAX_SERVERS 
printf "| %-30s %-10s || %-30s %-10s%s |\n" "SUM of gcs_server_processes" $SOMA_GCS 
printf "| %-30s %-10s || %-30s %-10s%s |\n" "SUM of processes" $SOMA_PROCESSES
printf "| %-30s %-10s || %-30s %-10s%s |\n" "SGA > 100GB?" 
echo "------------------------------------------------------------------------------------------"
echo "|                                 SCORE e ERROS ENCONTRADOS                              |"
echo "------------------------------------------------------------------------------------------"
printf "|                            SCORE FINAL  >>>> %-4s <<<<                                 |\n" $(echo| awk -v total="$subsecao_count" -v erros="${#SUMARIZA_ERRO[@]}" 'BEGIN{ printf("%.f%\n",((total-erros)/total)*100) }')
echo "|                                                                                        |"
printf "| %-30s %-10s    %-30s %-10s%s |\n" "ITEMS AVALIADOS" $subsecao_count  "ERROS ENCONTRADOS" ${#SUMARIZA_ERRO[@]}
echo "------------------------------------------------------------------------------------------"
for i in $(seq 1 ${#SUMARIZA_ERRO[@]}) 
do
  printf "| >> %-83s |\n" "${SUMARIZA_ERRO[$i]}";
done
if [[ $RAC_FOUND == "1" ]]; then RAC_FOUND="SIM"; else RAC_FOUND="NAO"; fi;
if [[ $OGG_FOUND == "1" ]]; then OGG_FOUND="SIM"; else OGG_FOUND="NAO"; fi;

echo "------------------------------------------------------------------------------------------"
echo "|                                       ENVIRONMENT                                      |"
echo "------------------------------------------------------------------------------------------"
echo " OS_VERSION.....: "$FULL_OS_VERSION
echo " RAC............: "$RAC_FOUND
echo " OGG RUNNING....: "$OGG_FOUND
echo " GRID_HOME......: "$GRID_HOME
echo " OUTPUT_DIR.....: "$OUTPUT_DIR
echo " OUTPUT_FILE....: "$FULL_OUTPUT_DIR".csv"
echo "------------------------------------------------------------------------------------------"
#END OF run_db_check.sh