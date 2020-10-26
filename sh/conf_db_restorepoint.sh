#! /usr/bin/env bash
#conf_db_restorepoint.sh
#Objetivo: Criacao automatica de restore point em todos os bancos do servidor
# -> REVISOES
#    20/03/2020  -  Criacao                                                     -   jose.juliano@telefonica.com

##VARs
BASENAME=$(basename $0 .sh)
GRID_HOME=$(ps -ef | grep d.bin | grep -v grep | grep ocssd.bin | awk {' print $8 '} | sed -n "s/bin\/\ocssd.bin//p")
OUTPUT_DIR=$WORKDIR/dbaops/output/$BASENAME
SH_DIR=$WORKDIR/dbaops/sh
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
  user_error=0
  #sai com erro se usuario nao for o dono do banco
  for i in $(ps -ef | grep pmon | egrep -v "ASM|grep|APX|MGMTDB" | awk {' print $1 '} |sort -u); 
  do
      if [ $USER = "$i" ]; then
        #let user_error++
        user_error=$((user_error+1))
      fi;
  done;  
  if [ "$user_error" = "0" ]; then
    echo -e "\nERROR: Somente o usuario dono da banco pode executar esse script\n"
    exit 1
  fi; 
  
  ##muda para diretorio sh
  #VOLTAR
  #cd $SH_DIR
  
  ##cria diretorio e/ou arquivos necessarios para execucao do script
  #VOLTAR
  if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
  fi
  
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
trap 'rm .dbrp_create* 2>/dev/null' 0                          #limpa temp files qd terminado


for i in $(ps -ef | grep pmon | egrep -v "ASM|grep|APX|MGMTDB" | awk {' print substr($8,10) '}); do
ORACLE_SID=$i
ORAENV_ASK=NO
. oraenv 1>/dev/null <<EOF
$ORACLE_SID
EOF

if [ "$1" == "create" ]; then
sqlplus -s / as sysdba <<EOF >.dbrp_create_$ORACLE_SID
set head off
set timi off
set time off
CREATE RESTORE POINT OGG_AMDOCS GUARANTEE FLASHBACK DATABASE;
EOF

echo $HOSTNAME" "$ORACLE_SID" "$1" "$(cat .dbrp_create_$ORACLE_SID|grep -v '*')

elif [ "$1" == "drop" ]; then
sqlplus -s / as sysdba <<EOF >.dbrp_create_$ORACLE_SID
set head off
set timi off
set time off
DROP RESTORE POINT OGG_AMDOCS;
EOF

echo $HOSTNAME" "$ORACLE_SID" "$1" "$(cat .dbrp_create_$ORACLE_SID|grep -v '*')

fi;

done