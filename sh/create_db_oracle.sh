#! /usr/bin/env bash
#Exibir o shape no resumo
#Detectar e sugerir o nome dos diskgroups
#Verificar permissoes no ORACLE_HOME selecionado
#Há um problema quando a variavel do ambiente esta setado para o GRID

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
#OUTPUT_DIR=$WORKDIR/dbaops/output/$BASENAME
LOG_DIR=$WORKDIR/dbaops/log/$BASENAME
SH_DIR=$WORKDIR/dbaops/dbagit/sh
#OUTPUT_FILE=$BASENAME
LOGFILE=$BASENAME
#CONFIG_DIR=/tmp/checagens/"$HOSTNAME"/settings.cfg
FULL_OS_VERSION=$(cat /etc/redhat-release)
OS_VERSION=$(cat /etc/redhat-release | awk {' print $7 '} | cut -d"." -f1)
RAC_FOUND=$(ps -ef | grep crsd.bin | grep -v grep | wc -l)
DTHR=$(date +"%Y%m%d%H%M")
#FULL_OUTPUT_DIR=$OUTPUT_DIR/$OUTPUT_FILE.$DTHR
FULL_LOGFILE_DIR=$LOG_DIR/$LOGFILE.$DTHR.log
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
  if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
  fi
  
}

fn_printcol()
{
  COL1=$1
  COL2=$2
  COL3=$3
  COL4=$4
  printf "%-.30s%s\n" "$COL1................................" ": $COL2 $COL3 $COL4"
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

fn_exit_error()
{
    echo -e "\nERROR: Codigo $1 - Linha $2\n"
    echo -e "$3\n"
    exit 1
}

fn_exit_ctrlc()
{
    echo -e "\nERROR: Interrompido pelo usuario. Codigo 2 - Linha $2\n"
    exit 2
}

fn_menu() {

ARGUSAGE="MODO DE USO: $(basename $0) -dbname <DBNAME> -oh <ORACLE_HOME> -shape [small|medium|large|list] -ref [#ticket remedy] -dryrun -h

EXEMPLO: $(basename $0) -dbname ODISAS -oh /u01/app/oracle/product/12.2.0.1/dbhome_1 -shape small
         Cria um novo banco de dados chamado ODISAS no oracle_home /u01/app/oracle/product/12.2.0.1/dbhome_1

  -dbname
      Define um nome para para o banco
      Parametro obrigatório 
  -oh
      Especifica o ORACLE_HOME a ser utilizado para criacao do banco
      Parametro obrigatório
  -shape
      Define o tamanho do banco small|medium|large Para mais informações $(basename $0) -shape list
      Parametro obrigatório
  -ref
      Numero do ticket no remedy
  -dryrun
      Somente faz uma checagem sem modificar nada
  -h ou -help
      Mostra as opções de ajuda
"
	
	while [ "$1" != "" ]
	do
	    case $1 in
  -dbname) dbname=$2 ;
			if [ ! -z "$dbname" ] ; then
				shift 2
			else
        trap - ERR
				echo -e "\nERROR: Nenhum valor fornecido para o parametro -dbname\n"
				exit 1
			fi
			;;
  -oh) oh=$2 ;
			if [ ! -z "$oh" ] ; then
				shift 2
			else
        trap - ERR
        echo -e "\nERROR: Nenhum valor fornecido para o parametro -oh\n"
				exit 1
			fi			
			;;
  -shape) shape=$2 ;
			if [ ! -z "$shape" ] ; then
				shift 2
			else
        trap - ERR
				echo -e "\nERROR: Nenhum valor fornecido para o parametro -shape\n"
				exit 1
			fi
			;;
  -ref) ref=$2 ;
			if [ ! -z "$ref" ] ; then
				shift 2
			else 
        trap - ERR
				echo -e "\nERROR: Nenhum valor fornecido para o parametro -ref\n"
				exit 1
			fi
			;;
  -dryrun) dryrun="yes";
      if [ ! -z "$dryrun" ] ; then
				shift 1
			fi
			;;			
  -h) 
			echo -e "\n$ARGUSAGE" >&2
            trap - ERR
            exit 1		
			;;
  -help) 
			echo -e "\n$ARGUSAGE" >&2
            trap - ERR
            exit 1		
			;;					
  *) echo -e "\nERROR:  "$1" não é um parametro valido."
			echo -e "\n$ARGUSAGE" >&2
			trap - ERR
      exit 1
	        ;;
		esac
		
	done

if  [ "$shape" != "list" ]; then 
  if  [ -z "$dbname" ]; then 
    trap - ERR
    echo -e "\nERROR: dbname nao especificado. Use opcao -h para ajuda\n"
    exit 1
  elif  [ -z "$oh" ]; then 
    trap - ERR
    echo -e "\nERROR: oh nao especificado. Use opcao -h para ajuda\n"
    exit 1
  elif  [ -z "$shape" ]; then 
    trap - ERR
    echo -e "\nERROR: shape nao especificado. Use opcao -h para ajuda\n"
    exit 1
  fi	
fi;

if ( [ "${shape,,}" != "small" ]  && [ "${shape,,}" != "medium" ] && [ "${shape,,}" != "large" ] && [ "${shape,,}" != "list" ] && [ "${shape,,}" != "vm" ] ) ; then
    trap - ERR
    echo -e "\nERROR: shape=${shape,,} Valor de -shape deve ser small, medium, large ou use list para ver mais informações\n"
		exit 0
fi

}

fn_shape(){
local ERROR_MESSAGE="Nao foi possivel obter URL para download" #Cria mensagem amigavel 
wget -O .shape_db http://10.240.42.99:9080/automacao/banco_de_dados/dbagit/raw/master/sh/.shape_db &>/dev/null

echo -e "\n-------------------------------------"
echo "|            SHAPE SMALL           |"
echo "-------------------------------------"
for  row in $(cat .shape_db |grep -i "^small")
do
 param=$(echo $row|cut -d',' -f2)
 value=$(echo $row|cut -d',' -f3)
  fn_printcol "${param}" "${value}"
done;

echo -e "\n-------------------------------------"
echo "|            SHAPE MEDIUM          |"
echo "-------------------------------------"
for  row in $(cat .shape_db |grep -i "^medium")
do
 param=$(echo $row|cut -d',' -f2)
 value=$(echo $row|cut -d',' -f3)
  fn_printcol "${param}" "${value}"
done;

echo -e "\n-------------------------------------"
echo "|            SHAPE LARGE           |"
echo "-------------------------------------"
for  row in $(cat .shape_db |grep -i "^large")
do
 param=$(echo $row|cut -d',' -f2)
 value=$(echo $row|cut -d',' -f3)
  fn_printcol "${param}" "${value}"
done;
echo -e "\n"
}

fn_create_db(){
local ORACLE_HOME=$1
local DBNAME=$2
local SHAPE=$3
#USAGE:
#./deploy_db_home.sh -ohname=BASE11204_7 -ohfolder=/u01/app/oracle/product/19.6.0.0/dbhome_1 -patchid=3
echo -e "\n####VALIDANDO PREREQs PARA INSTALACAO####\n"

#INICIO DO QUESTIONARIO
while true; do
    read -p "Qual o tipo de instalacao? [1-RAC | 2-Single]: " yn
    case $yn in
        [1]*) TIPO_INSTALACAO="RAC"; break;;
        [2]*) TIPO_INSTALACAO="SI"; break;;
        * ) echo "  Opcao invalida.";;
    esac
done;

if [ "$TIPO_INSTALACAO" == 'RAC' ]; then
while true; do
    read -p "Quantidade de nodes: " yn
    if [ "$yn" -le "1" ]; then 
    echo "  Opcao invalida. Digite valor maior que 1"; 
    else
      case $yn in
           [1]*) QTD_NODES="$yn"; break;;
           [2]*) QTD_NODES="$yn"; break;;
           [3]*) QTD_NODES="$yn"; break;;
           [4]*) QTD_NODES="$yn"; break;;
           [5]*) QTD_NODES="$yn"; break;;
           [6]*) QTD_NODES="$yn"; break;;
           [7]*) QTD_NODES="$yn"; break;;
           [8]*) QTD_NODES="$yn"; break;;
           [9]*) QTD_NODES="$yn"; break;;
          * ) echo "  Opcao invalida. Digite somente numeros";;
      esac
    fi;
done;

while true; do
read -p "Informe o nome dos nodes(use virgula para separar): " NODE_LIST
CONTAVIRGULA=$(echo $NODE_LIST|grep -o ","|wc -l) ##VERIFICA QTD DE VIRGULAS NA STRING
COMPARAVIRGULA=$(echo |awk -v qtd_nodes="${QTD_NODES}" 'BEGIN{print (qtd_nodes-1)}') ##DIMINUI UMA VIRGULA
if [ "$CONTAVIRGULA" != "$COMPARAVIRGULA" ]; then #quantidade de virgula nao eh igual a qtd_nodes-1
  echo "  Opcao invalida! Necessario ${QTD_NODES} nodes, mas encontrado-> ${NODE_LIST} ";
else
  break;  #sai do loop
fi;
done;

##SEPARA O NOME DOS HOSTS PARA APRESENTAR NO SUMMARY
for i in $(seq 1 "$CONTAVIRGULA")
do
  NODE[$i]=$(echo $NODE_LIST|cut -d',' -f${i})
done;

fi; ##FIMRAC

while true; do
    read -p "Informe o charset [1-WE8ISO8859P1 | 2-AL32UTF8 | 3-WE8ISO8859P15 | 4-WE8MSWIN1252| 5-UTF8]: " yn
    case $yn in
        [1]*) CHARSET="WE8ISO8859P1"; break;;
        [2]*) CHARSET="AL32UTF8"; break;;
        [3]*)  CHARSET="WE8ISO8859P15"; break;; 
        [4]*)  CHARSET="WE8MSWIN1252"; break;;
        [5]*)  CHARSET="UTF8"; break;;        
        * ) echo "  Opcao invalida.";;
    esac
done

#printa confirmação antes de prosseguir
while true; do
    read -p "Deseja modificar a senha padrao do SYS e SYSTEM [Ss|Nn] " yn
    case $yn in
        [Ss]* ) read -s -p "Senha do SYS: " PASS1; echo; read -s -p "Senha do SYSTEM: " PASS2; echo; break;;
        [Nn]* ) PASS1="vsq#$(echo ${DBNAME,,}|cut -c1-3)#0"; PASS2="vsq#$(echo ${DBNAME,,}|cut -c1-3)#1"; break;;
        * ) echo "Por favor responda sim[Ss] ou nao[Nn].";;
    esac
done

#printa confirmação antes de prosseguir
while true; do
    read -p "Deseja modificar o nome padrão de DISKGROUPs? [Ss|Nn] " yn
    case $yn in
        [Ss]* ) read -p "Informe DG Dados: " DGDADOS; read -p "Informe DG Archive: " DGARCHIVE; read -p "Informe DG Redo1: " DGREDO1; read -p "Informe DG Redo2: " DGREDO2; break;;
        [Nn]* ) DGDADOS="+DG_${DBNAME^^}_DATA_01"; DGARCHIVE="+DG_${DBNAME^^}_ARCH_01"; DGREDO1="+DG_${DBNAME^^}_REDO_01"; DGREDO2="+DG_${DBNAME^^}_REDO_02"; break;;
        * ) echo "Por favor responda sim[Ss] ou nao[Nn].";;
    esac
done

##->Adicionar validacao de diskgroup
##->Adicionar validacao de redes
#CHECK PREREQS - Espaço
OH_FREE_SPACE=$(df -Pk $ORACLE_HOME |grep -v "Filesystem" |awk {' print $4 '})
echo -ne '-> Checando espaço livre no filesystem.........\r\c'
if [ "$OH_FREE_SPACE" -lt "20971520" ]; then                                        #se tiver menos que 10GB livre no OH
  fn_exit_error "1" "$LINENO" "Nao ha espaco suficiente no filesystem para criar o banco(20GB)"
else  
  sleep 2
  echo -ne '-> Checando espaço livre no filesystem.........[OK]\r'
  echo -ne '\n'
fi;
OH_TRACE_FREE=$(df -Pk /dbs/trace |grep -v "Filesystem" |awk {' print $4 '})
echo -ne '-> Checando espaço /dbs/trace..................\r\c'
if [ "$OH_TRACE_FREE" -lt "5242880" ]; then                                  #se trace filesytem for menor que 5GB
  fn_exit_error "1" "$LINENO" "Nao ha espaco suficiente no /dbs/trace criar o banco(5GB)"
else  
  sleep 2
  echo -ne '-> Checando espaço /dbs/trace..................[OK]\r'
  echo -ne '\n'
fi;

#CHECK PREREQS - HUGEPAGES
HPFREE=$(cat /proc/meminfo | grep -i HugePages_Free | sed -n "s/://p" | awk {' print $2 '})
HPFREE_KB=$(echo| awk -v hpsize="$HPFREE" 'BEGIN{ printf("%.f\n",((hpsize*2048)/1) )}')
  echo -ne '-> Checando espaço livre no HUGEPAGES..........\r\c'
if [ "$HPFREE_KB" -lt "26214400" ] && [ "$shape" == "small" ]; then                                        #se tiver menos que 10GB livre no OH
  fn_exit_error "1" "$LINENO" "Nao ha hugepages suficiente para criar o banco(25GB)"
elif [ "$HPFREE_KB" -lt "52428800" ] && [ "$shape" == "medium" ]; then                                        #se tiver menos que 10GB livre no OH
  fn_exit_error "1" "$LINENO" "Nao ha hugepages suficiente para criar o banco(50GB)"
elif [ "$HPFREE_KB" -lt "104857600" ] && [ "$shape" == "large" ]; then                                        #se tiver menos que 10GB livre no OH
  fn_exit_error "1" "$LINENO" "Nao ha hugepages suficiente para criar o banco(100GB)"
else  
  sleep 2
  echo -ne '-> Checando espaço livre no HUGEPAGES..........[OK]\r'
  echo -ne '\n'
fi;

##SUMARIO
echo -e "\n--------------------------------------------------------------------------------------------------"
echo "|                                               RESUMO                                           |"
echo "--------------------------------------------------------------------------------------------------"
fn_printcol "ORACLE_HOME" "${ORACLE_HOME}"
fn_printcol "DBNAME" "${DBNAME}"
fn_printcol "SHAPE" "${SHAPE}"
fn_printcol "CHARSET" "${CHARSET}"
fn_printcol "INSTALACAO" "${TIPO_INSTALACAO}"
if [ "${TIPO_INSTALACAO}" != "SI" ]; then
fn_printcol "QTD_NODES" "${QTD_NODES}"
fn_printcol "NODES" "${NODE_LIST}"
fi;
fn_printcol "DG_DADOS" "${DGDADOS^^}"
fn_printcol "DG_ARCHIVE" "${DGARCHIVE^^}"
fn_printcol "DG_REDO1" "${DGREDO1^^}"
fn_printcol "DG_REDO2" "${DGREDO2^^}"

echo -e "\n"
#printa confirmação antes de prosseguir
while true; do
    read -p "Um novo banco será criado. Deseja prosseguir? [Ss|Nn] " yn
    case $yn in
        [Ss]* ) break;;
        [Nn]* ) echo -e "\n>>ENCERRANDO SCRIPT<<\n"; exit;;
        * ) echo "Por favor responda sim ou nao.";;
    esac
done

echo -e "\n####INICIANDO CRIACAO DO BANCO ${DBNAME} ####\n" >> $FULL_LOGFILE_DIR
fn_printcol "ORACLE_HOME" "${ORACLE_HOME}" >> $FULL_LOGFILE_DIR
fn_printcol "DBNAME" "${DBNAME}" >> $FULL_LOGFILE_DIR
fn_printcol "SHAPE" "${SHAPE}" >> $FULL_LOGFILE_DIR
fn_printcol "CHARSET" "${CHARSET}" >> $FULL_LOGFILE_DIR
fn_printcol "INSTALACAO" "${TIPO_INSTALACAO}" >> $FULL_LOGFILE_DIR
fn_printcol "QTD_NODES" "${QTD_NODES}" >> $FULL_LOGFILE_DIR
fn_printcol "NODES" "${NODE_LIST}" >> $FULL_LOGFILE_DIR
fn_printcol "DG_DADOS" "${DGDADOS^^}" >> $FULL_LOGFILE_DIR
fn_printcol "DG_ARCHIVE" "${DGARCHIVE^^}" >> $FULL_LOGFILE_DIR
fn_printcol "DG_REDO1" "${DGREDO1^^}" >> $FULL_LOGFILE_DIR
fn_printcol "DG_REDO2" "${DGREDO2^^}" >> $FULL_LOGFILE_DIR
echo -e "\n" >> $FULL_LOGFILE_DIR

echo -e "\nLOG COMPLETO: $FULL_LOGFILE_DIR"


#12c
echo "responseFileVersion=/oracle/assistants/rspfmt_dbca_response_schema_v12.2.0" >>db.rsp
echo "gdbName=${DBNAME}" >>db.rsp
echo "sid=${DBNAME}" >>db.rsp
echo "databaseConfigType=${TIPO_INSTALACAO}" >>db.rsp
echo "RACOneNodeServiceName=" >>db.rsp
echo "policyManaged=false" >>db.rsp
echo "createServerPool=false" >>db.rsp
echo "serverPoolName=" >>db.rsp
echo "cardinality=" >>db.rsp
echo "force=false" >>db.rsp
echo "pqPoolName=" >>db.rsp
echo "pqCardinality=" >>db.rsp
echo "createAsContainerDatabase=false" >>db.rsp
echo "numberOfPDBs=0" >>db.rsp
echo "pdbName=" >>db.rsp
echo "useLocalUndoForPDBs=true" >>db.rsp
echo "pdbAdminPassword=" >>db.rsp
echo "nodelist=${NODE_LIST}" >>db.rsp
echo "templateName=${SH_DIR}/template.dbt" >>db.rsp
echo "sysPassword=${PASS1}" >>db.rsp
echo "systemPassword=${PASS2}" >>db.rsp
echo "serviceUserPassword=" >>db.rsp
echo "emConfiguration=" >>db.rsp
echo "emExpressPort=5500" >>db.rsp
echo "runCVUChecks=false" >>db.rsp
echo "dbsnmpPassword=" >>db.rsp
echo "omsHost=" >>db.rsp
echo "omsPort=0" >>db.rsp
echo "emUser=" >>db.rsp
echo "emPassword=" >>db.rsp
echo "dvConfiguration=false" >>db.rsp
echo "dvUserName=" >>db.rsp
echo "dvUserPassword=" >>db.rsp
echo "dvAccountManagerName=" >>db.rsp
echo "dvAccountManagerPassword=" >>db.rsp
echo "olsConfiguration=false" >>db.rsp
echo "datafileJarLocation=" >>db.rsp
echo "datafileDestination=${DGDADOS^^}/{DB_UNIQUE_NAME}/" >>db.rsp
echo "recoveryAreaDestination=" >>db.rsp
echo "storageType=ASM" >>db.rsp
echo "diskGroupName=${DGDADOS^^}/{DB_UNIQUE_NAME}/" >>db.rsp
echo "asmsnmpPassword=" >>db.rsp
echo "recoveryGroupName=" >>db.rsp
echo "characterSet=${CHARSET}" >>db.rsp
echo "nationalCharacterSet=AL16UTF16" >>db.rsp
echo "registerWithDirService=false" >>db.rsp
echo "dirServiceUserName=" >>db.rsp
echo "dirServicePassword=" >>db.rsp
echo "walletPassword=" >>db.rsp
echo "listeners=" >>db.rsp
echo "variablesFile=" >>db.rsp
echo "variables=DB_UNIQUE_NAME=${DBNAME,,},ORACLE_BASE=/u01/app/oracle,PDB_NAME=,DB_NAME=${DBNAME,,},ORACLE_HOME=${ORACLE_HOME},SID=${DBNAME,,}" >>db.rsp
if [ "$TIPO_INSTALACAO" == 'RAC' ]; then ##VALIDA TIPO DA INSTALACAO
  for i in $(seq 1 $QTD_NODES)
  do
    PARAMETRO=$PARAMETRO",${DBNAME^^}${i}.undo_tablespace=UNDOTBS${i},${DBNAME^^}${i}.instance_number=${i},${DBNAME^^}${i}.thread=${i}"
  done;
  PARAMETRO=$PARAMETRO",cluster_database=true"
else
  PARAMETRO=",undo_tablespace=UNDOTBS1"
fi;
if [ "$shape" == "vm" ]; then
  large_page_param="use_large_pages=TRUE,"
else
  large_page_param="use_large_pages=ONLY,"
fi;
##VALIDA SHAPE
local ERROR_MESSAGE="Nao foi possivel obter URL para download do shape" #Cria mensagem amigavel 
wget -O .shape_db http://10.240.42.99:9080/automacao/banco_de_dados/dbagit/raw/master/sh/.shape_db &>/dev/null

for row in $(cat .shape_db |grep -i "^${SHAPE,,}")
do
 param=$(echo ${row,,}|cut -d',' -f2)
 value=$(echo $row|cut -d',' -f3)
  paramshape=${paramshape}${param}"="${value}","
done;
##sga_target colocar igual sga_max_size
##db_files nao funcionou, adicionar no shape
echo "initParams=${paramshape}db_create_online_log_dest_2=${DGREDO2^^},db_create_online_log_dest_1=${DGREDO1^^},log_archive_dest_1='LOCATION=${DGARCHIVE^^}',${large_page_param}log_checkpoint_interval=180,nls_language=AMERICAN,dispatchers=(PROTOCOL=TCP) (SERVICE=${DBNAME^^}XDB),db_files=5000,log_checkpoints_to_alert=TRUE,db_block_size=8192BYTES,diagnostic_dest=/dbs/trace,audit_file_dest=/dbs/trace/admin/${DBNAME,,}/adump,db_create_file_dest=${DGDADOS^^}/{DB_UNIQUE_NAME}/,nls_territory=AMERICA,log_archive_format=arc_%t_%s_%r.arc,os_authent_prefix=,compatible=12.2.0.1,db_name=${DBNAME,,},audit_trail=NONE,remote_login_passwordfile=EXCLUSIVE,recyclebin=OFF,open_cursors=1000${PARAMETRO}" >>db.rsp
echo "sampleSchema=false" >>db.rsp
echo "memoryPercentage=40" >>db.rsp
echo "databaseType=MULTIPURPOSE" >>db.rsp
echo "automaticMemoryManagement=false" >>db.rsp
echo "totalMemory=0" >>db.rsp


#DB SHAPE12c
echo "<DatabaseTemplate name=\"dbca_12201\" description=\"\" version=\"12.2.0.1.0\">" >> template.dbt
echo "   <CommonAttributes>" >> template.dbt
echo "      <option name=\"OMS\" value=\"false\"/>" >> template.dbt
echo "      <option name=\"JSERVER\" value=\"false\"/>" >> template.dbt
echo "      <option name=\"SPATIAL\" value=\"false\"/>" >> template.dbt
echo "      <option name=\"IMEDIA\" value=\"false\"/>" >> template.dbt
echo "      <option name=\"ORACLE_TEXT\" value=\"false\">" >> template.dbt
echo "         <tablespace id=\"SYSAUX\"/>" >> template.dbt
echo "      </option>" >> template.dbt
echo "      <option name=\"SAMPLE_SCHEMA\" value=\"false\"/>" >> template.dbt
echo "      <option name=\"CWMLITE\" value=\"false\">" >> template.dbt
echo "         <tablespace id=\"SYSAUX\"/>" >> template.dbt
echo "      </option>" >> template.dbt
echo "      <option name=\"APEX\" value=\"false\"/>" >> template.dbt
echo "      <option name=\"DV\" value=\"false\"/>" >> template.dbt
echo "   </CommonAttributes>" >> template.dbt
echo "   <Variables/>" >> template.dbt
echo "   <CustomScripts Execute=\"false\"/>" >> template.dbt
echo "   <InitParamAttributes>" >> template.dbt
echo "      <InitParams>" >> template.dbt
echo "         <initParam name=\"log_archive_dest_1\" value=\"'LOCATION=${DGARCHIVE^^}'\"/>" >> template.dbt
echo "         <initParam name=\"db_files\" value=\"5000\"/>" >> template.dbt
echo "         <initParam name=\"log_archive_format\" value=\"arc_%t_%s_%r.arc\"/>" >> template.dbt
echo "         <initParam name=\"db_block_size\" value=\"8192\"/>" >> template.dbt
echo "         <initParam name=\"open_cursors\" value=\"300\"/>" >> template.dbt
echo "         <initParam name=\"db_name\" value=\"${DBNAME,,}\"/>" >> template.dbt
echo "         <initParam name=\"db_create_file_dest\" value=\"${DGDADOS^^}\"/>" >> template.dbt
echo "         <initParam name=\"db_create_online_log_dest_1\" value=\"${DGREDO1^^}\"/>" >> template.dbt
echo "         <initParam name=\"db_create_online_log_dest_2\" value=\"${DGREDO2^^}\"/>" >> template.dbt
echo "         <initParam name=\"compatible\" value=\"19.0.0\"/>" >> template.dbt
echo "         <initParam name=\"diagnostic_dest\" value=\"/dbs/trace\"/>" >> template.dbt
echo "         <initParam name=\"recyclebin\" value=\"OFF\"/>" >> template.dbt
echo "         <initParam name=\"nls_language\" value=\"AMERICAN\"/>" >> template.dbt
echo "         <initParam name=\"nls_territory\" value=\"AMERICA\"/>" >> template.dbt
echo "         <initParam name=\"processes\" value=\"1200\"/>" >> template.dbt
echo "         <initParam name=\"log_checkpoints_to_alert\" value=\"TRUE\"/>" >> template.dbt
echo "         <initParam name=\"sga_target\" value=\"6144\" unit=\"MB\"/>" >> template.dbt
echo "         <initParam name=\"audit_file_dest\" value=\"/dbs/trace/admin/${DBNAME,,}/adump\"/>" >> template.dbt
echo "         <initParam name=\"audit_trail\" value=\"NONE\"/>" >> template.dbt
if [ "$shape" == "vm" ]; then
  echo "         <initParam name=\"use_large_pages\" value=\"TRUE\"/>" >> template.dbt
else
  echo "         <initParam name=\"use_large_pages\" value=\"ONLY\"/>" >> template.dbt
fi;
echo "         <initParam name=\"log_checkpoint_interval\" value=\"180\"/>" >> template.dbt
echo "         <initParam name=\"os_authent_prefix\" value=\"\"/>" >> template.dbt
echo "         <initParam name=\"remote_login_passwordfile\" value=\"EXCLUSIVE\"/>" >> template.dbt
echo "         <initParam name=\"dispatchers\" value=\"(PROTOCOL=TCP) (SERVICE=${DBNAME^^}XDB)\"/>" >> template.dbt
echo "         <initParam name=\"pga_aggregate_target\" value=\"2048\" unit=\"MB\"/>" >> template.dbt
#echo "         <initParam name=\"undo_tablespace\" value=\"UNDOTBS1\"/>"<<< >> template.dbt
echo "         <initParam name=\"sec_case_sensitive_logon\" value=\"FALSE\"/>" >> template.dbt
echo "      </InitParams>" >> template.dbt
echo "      <MiscParams>" >> template.dbt
echo "         <databaseType>MULTIPURPOSE</databaseType>" >> template.dbt
echo "         <maxUserConn>20</maxUserConn>" >> template.dbt
echo "         <percentageMemTOSGA>40</percentageMemTOSGA>" >> template.dbt
echo "         <customSGA>false</customSGA>" >> template.dbt
echo "         <characterSet>${CHARSET}</characterSet>" >> template.dbt
echo "         <nationalCharacterSet>AL16UTF16</nationalCharacterSet>" >> template.dbt
echo "         <archiveLogMode>true</archiveLogMode>" >> template.dbt
echo "         <initParamFileName>{ORACLE_BASE}/admin/{DB_UNIQUE_NAME}/pfile/init.ora</initParamFileName>" >> template.dbt
echo "      </MiscParams>" >> template.dbt
echo "      <SPfile useSPFile=\"true\">${DGDADOS^^}/${DBNAME^^}/spfile${DBNAME^^}.ora</SPfile> " >> template.dbt
echo "   </InitParamAttributes>" >> template.dbt
echo "   <StorageAttributes>" >> template.dbt
echo "      <ControlfileAttributes id=\"Controlfile\">" >> template.dbt
echo "         <maxDatafiles>5000</maxDatafiles>" >> template.dbt
echo "         <maxLogfiles>16</maxLogfiles>" >> template.dbt
echo "         <maxLogMembers>3</maxLogMembers>" >> template.dbt
echo "         <maxLogHistory>1</maxLogHistory>" >> template.dbt
echo "         <maxInstances>8</maxInstances>" >> template.dbt
echo "         <image name=\"control01.ctl\" filepath=\"${DGREDO1^^}/{DB_UNIQUE_NAME}/\"/>" >> template.dbt
echo "         <image name=\"control02.ctl\" filepath=\"${DGREDO2^^}/{DB_UNIQUE_NAME}/\"/>" >> template.dbt
echo "      </ControlfileAttributes>" >> template.dbt
echo "      <DatafileAttributes id=\"${DGDADPS}/sysaux01.dbf\" con_id=\"1\">" >> template.dbt
echo "         <tablespace>SYSAUX</tablespace>" >> template.dbt
echo "         <temporary>false</temporary>" >> template.dbt
echo "         <online>true</online>" >> template.dbt
echo "         <status>0</status>" >> template.dbt
echo "         <size unit=\"MB\">550</size>" >> template.dbt
echo "         <reuse>true</reuse>" >> template.dbt
echo "         <autoExtend>true</autoExtend>" >> template.dbt
echo "         <increment unit=\"KB\">10240</increment>" >> template.dbt
echo "         <maxSize unit=\"MB\">-1</maxSize>" >> template.dbt
echo "      </DatafileAttributes>" >> template.dbt
echo "      <DatafileAttributes id=\"${DGDADOS^^}/system01.dbf\" con_id=\"1\">" >> template.dbt
echo "         <tablespace>SYSTEM</tablespace>" >> template.dbt
echo "         <temporary>false</temporary>" >> template.dbt
echo "         <online>true</online>" >> template.dbt
echo "         <status>0</status>" >> template.dbt
echo "         <size unit=\"MB\">700</size>" >> template.dbt
echo "         <reuse>true</reuse>" >> template.dbt
echo "         <autoExtend>true</autoExtend>" >> template.dbt
echo "         <increment unit=\"KB\">10240</increment>" >> template.dbt
echo "         <maxSize unit=\"MB\">-1</maxSize>" >> template.dbt
echo "      </DatafileAttributes>" >> template.dbt
echo "      <DatafileAttributes id=\"${DGDADOS^^}/temp01.dbf\" con_id=\"1\">" >> template.dbt
echo "         <tablespace>TEMP</tablespace>" >> template.dbt
echo "         <temporary>false</temporary>" >> template.dbt
echo "         <online>true</online>" >> template.dbt
echo "         <status>0</status>" >> template.dbt
echo "         <size unit=\"MB\">20</size>" >> template.dbt
echo "         <reuse>true</reuse>" >> template.dbt
echo "         <autoExtend>true</autoExtend>" >> template.dbt
echo "         <increment unit=\"KB\">640</increment>" >> template.dbt
echo "         <maxSize unit=\"MB\">-1</maxSize>" >> template.dbt
echo "      </DatafileAttributes>" >> template.dbt
echo "      <DatafileAttributes id=\"${DGDADOS^^}/undotbs01.dbf\" con_id=\"1\">" >> template.dbt
echo "         <tablespace>UNDOTBS1</tablespace>" >> template.dbt
echo "         <temporary>false</temporary>" >> template.dbt
echo "         <online>true</online>" >> template.dbt
echo "         <status>0</status>" >> template.dbt
echo "         <size unit=\"MB\">200</size>" >> template.dbt
echo "         <reuse>true</reuse>" >> template.dbt
echo "         <autoExtend>true</autoExtend>" >> template.dbt
echo "         <increment unit=\"KB\">5120</increment>" >> template.dbt
echo "         <maxSize unit=\"MB\">-1</maxSize>" >> template.dbt
echo "      </DatafileAttributes>" >> template.dbt
echo "      <DatafileAttributes id=\"${DGDADOS^^}/users01.dbf\" con_id=\"1\">" >> template.dbt
echo "         <tablespace>USERS</tablespace>" >> template.dbt
echo "         <temporary>false</temporary>" >> template.dbt
echo "         <online>true</online>" >> template.dbt
echo "         <status>0</status>" >> template.dbt
echo "         <size unit=\"MB\">5</size>" >> template.dbt
echo "         <reuse>true</reuse>" >> template.dbt
echo "         <autoExtend>true</autoExtend>" >> template.dbt
echo "         <increment unit=\"KB\">1280</increment>" >> template.dbt
echo "         <maxSize unit=\"MB\">-1</maxSize>" >> template.dbt
echo "      </DatafileAttributes>" >> template.dbt
echo "      <TablespaceAttributes id=\"SYSAUX\" con_id=\"1\">" >> template.dbt
echo "         <temporary>false</temporary>" >> template.dbt
echo "         <defaultTemp>false</defaultTemp>" >> template.dbt
echo "         <undo>false</undo>" >> template.dbt
echo "         <local>true</local>" >> template.dbt
echo "         <blockSize>-1</blockSize>" >> template.dbt
echo "         <allocation>1</allocation>" >> template.dbt
echo "         <uniAllocSize unit=\"KB\">-1</uniAllocSize>" >> template.dbt
echo "         <initSize unit=\"KB\">64</initSize>" >> template.dbt
echo "         <increment unit=\"KB\">64</increment>" >> template.dbt
echo "         <incrementPercent>50</incrementPercent>" >> template.dbt
echo "         <minExtends>1</minExtends>" >> template.dbt
echo "         <maxExtends>4096</maxExtends>" >> template.dbt
echo "         <minExtendsSize unit=\"KB\">64</minExtendsSize>" >> template.dbt
echo "         <logging>true</logging>" >> template.dbt
echo "         <recoverable>false</recoverable>" >> template.dbt
echo "         <maxFreeSpace>0</maxFreeSpace>" >> template.dbt
echo "         <autoSegmentMgmt>true</autoSegmentMgmt>" >> template.dbt
echo "         <bigfile>false</bigfile>" >> template.dbt
echo "         <datafilesList>" >> template.dbt
echo "            <TablespaceDatafileAttributes id=\"${DGDADOS^^}/sysaux01.dbf\"/>" >> template.dbt
echo "         </datafilesList>" >> template.dbt
echo "      </TablespaceAttributes>" >> template.dbt
echo "      <TablespaceAttributes id=\"SYSTEM\" con_id=\"1\">" >> template.dbt
echo "         <temporary>false</temporary>" >> template.dbt
echo "         <defaultTemp>false</defaultTemp>" >> template.dbt
echo "         <undo>false</undo>" >> template.dbt
echo "         <local>true</local>" >> template.dbt
echo "         <blockSize>-1</blockSize>" >> template.dbt
echo "         <allocation>3</allocation>" >> template.dbt
echo "         <uniAllocSize unit=\"KB\">-1</uniAllocSize>" >> template.dbt
echo "         <initSize unit=\"KB\">64</initSize>" >> template.dbt
echo "         <increment unit=\"KB\">64</increment>" >> template.dbt
echo "         <incrementPercent>50</incrementPercent>" >> template.dbt
echo "         <minExtends>1</minExtends>" >> template.dbt
echo "         <maxExtends>-1</maxExtends>" >> template.dbt
echo "         <minExtendsSize unit=\"KB\">64</minExtendsSize>" >> template.dbt
echo "         <logging>true</logging>" >> template.dbt
echo "         <recoverable>false</recoverable>" >> template.dbt
echo "         <maxFreeSpace>0</maxFreeSpace>" >> template.dbt
echo "         <autoSegmentMgmt>true</autoSegmentMgmt>" >> template.dbt
echo "         <bigfile>false</bigfile>" >> template.dbt
echo "         <datafilesList>" >> template.dbt
echo "            <TablespaceDatafileAttributes id=\"${DGDADOS^^}/system01.dbf\"/>" >> template.dbt
echo "         </datafilesList>" >> template.dbt
echo "      </TablespaceAttributes>" >> template.dbt
echo "      <TablespaceAttributes id=\"TEMP\" con_id=\"1\">" >> template.dbt
echo "         <temporary>true</temporary>" >> template.dbt
echo "         <defaultTemp>true</defaultTemp>" >> template.dbt
echo "         <undo>false</undo>" >> template.dbt
echo "         <local>true</local>" >> template.dbt
echo "         <blockSize>-1</blockSize>" >> template.dbt
echo "         <allocation>1</allocation>" >> template.dbt
echo "         <uniAllocSize unit=\"KB\">-1</uniAllocSize>" >> template.dbt
echo "         <initSize unit=\"KB\">64</initSize>" >> template.dbt
echo "         <increment unit=\"KB\">64</increment>" >> template.dbt
echo "         <incrementPercent>0</incrementPercent>" >> template.dbt
echo "         <minExtends>1</minExtends>" >> template.dbt
echo "         <maxExtends>0</maxExtends>" >> template.dbt
echo "         <minExtendsSize unit=\"KB\">64</minExtendsSize>" >> template.dbt
echo "         <logging>true</logging>" >> template.dbt
echo "         <recoverable>false</recoverable>" >> template.dbt
echo "         <maxFreeSpace>0</maxFreeSpace>" >> template.dbt
echo "         <autoSegmentMgmt>true</autoSegmentMgmt>" >> template.dbt
echo "         <bigfile>false</bigfile>" >> template.dbt
echo "         <datafilesList>" >> template.dbt
echo "            <TablespaceDatafileAttributes id=\"${DGDADOS^^}/temp01.dbf\"/>" >> template.dbt
echo "         </datafilesList>" >> template.dbt
echo "      </TablespaceAttributes>" >> template.dbt
echo "      <TablespaceAttributes id=\"UNDOTBS1\" con_id=\"1\">" >> template.dbt
echo "         <temporary>false</temporary>" >> template.dbt
echo "         <defaultTemp>false</defaultTemp>" >> template.dbt
echo "         <undo>true</undo>" >> template.dbt
echo "         <local>true</local>" >> template.dbt
echo "         <blockSize>-1</blockSize>" >> template.dbt
echo "         <allocation>1</allocation>" >> template.dbt
echo "         <uniAllocSize unit=\"KB\">-1</uniAllocSize>" >> template.dbt
echo "         <initSize unit=\"KB\">512</initSize>" >> template.dbt
echo "         <increment unit=\"KB\">512</increment>" >> template.dbt
echo "         <incrementPercent>50</incrementPercent>" >> template.dbt
echo "         <minExtends>8</minExtends>" >> template.dbt
echo "         <maxExtends>4096</maxExtends>" >> template.dbt
echo "         <minExtendsSize unit=\"KB\">512</minExtendsSize>" >> template.dbt
echo "         <logging>true</logging>" >> template.dbt
echo "         <recoverable>false</recoverable>" >> template.dbt
echo "         <maxFreeSpace>0</maxFreeSpace>" >> template.dbt
echo "         <autoSegmentMgmt>true</autoSegmentMgmt>" >> template.dbt
echo "         <bigfile>false</bigfile>" >> template.dbt
echo "         <datafilesList>" >> template.dbt
echo "            <TablespaceDatafileAttributes id=\"${DGDADOS^^}/undotbs01.dbf\"/>" >> template.dbt
echo "         </datafilesList>" >> template.dbt
echo "      </TablespaceAttributes>" >> template.dbt
echo "      <TablespaceAttributes id=\"USERS\" con_id=\"1\">" >> template.dbt
echo "         <temporary>false</temporary>" >> template.dbt
echo "         <defaultTemp>false</defaultTemp>" >> template.dbt
echo "         <undo>false</undo>" >> template.dbt
echo "         <local>true</local>" >> template.dbt
echo "         <blockSize>-1</blockSize>" >> template.dbt
echo "         <allocation>1</allocation>" >> template.dbt
echo "         <uniAllocSize unit=\"KB\">-1</uniAllocSize>" >> template.dbt
echo "         <initSize unit=\"KB\">128</initSize>" >> template.dbt
echo "         <increment unit=\"KB\">128</increment>" >> template.dbt
echo "         <incrementPercent>0</incrementPercent>" >> template.dbt
echo "         <minExtends>1</minExtends>" >> template.dbt
echo "         <maxExtends>4096</maxExtends>" >> template.dbt
echo "         <minExtendsSize unit=\"KB\">128</minExtendsSize>" >> template.dbt
echo "         <logging>true</logging>" >> template.dbt
echo "         <recoverable>false</recoverable>" >> template.dbt
echo "         <maxFreeSpace>0</maxFreeSpace>" >> template.dbt
echo "         <autoSegmentMgmt>true</autoSegmentMgmt>" >> template.dbt
echo "         <bigfile>false</bigfile>" >> template.dbt
echo "         <datafilesList>" >> template.dbt
echo "            <TablespaceDatafileAttributes id=\"${DGDADOS^^}/users01.dbf\"/>" >> template.dbt
echo "         </datafilesList>" >> template.dbt
echo "      </TablespaceAttributes>" >> template.dbt
echo "      <RedoLogGroupAttributes id=\"1\">" >> template.dbt
echo "         <reuse>false</reuse>" >> template.dbt
echo "         <fileSize unit=\"KB\">2097152</fileSize>" >> template.dbt
echo "         <Thread>1</Thread>" >> template.dbt
echo "         <member ordinal=\"0\" memberName=\"redo01.log\" filepath=\"${DGREDO1^^}/${DBNAME^^}/\"/>" >> template.dbt
echo "      </RedoLogGroupAttributes>" >> template.dbt
echo "      <RedoLogGroupAttributes id=\"2\">" >> template.dbt
echo "         <reuse>false</reuse>" >> template.dbt
echo "         <fileSize unit=\"KB\">2097152</fileSize>" >> template.dbt
echo "         <Thread>1</Thread>" >> template.dbt
echo "         <member ordinal=\"0\" memberName=\"redo02.log\" filepath=\"${DGREDO1^^}/${DBNAME^^}/\"/>" >> template.dbt
echo "      </RedoLogGroupAttributes>" >> template.dbt
echo "      <RedoLogGroupAttributes id=\"3\">" >> template.dbt
echo "         <reuse>false</reuse>" >> template.dbt
echo "         <fileSize unit=\"KB\">2097152</fileSize>" >> template.dbt
echo "         <Thread>1</Thread>" >> template.dbt
echo "         <member ordinal=\"0\" memberName=\"redo03.log\" filepath=\"${DGREDO1^^}/${DBNAME^^}/\"/>" >> template.dbt
echo "      </RedoLogGroupAttributes>" >> template.dbt
echo "      <RedoLogGroupAttributes id=\"4\">" >> template.dbt
echo "         <reuse>false</reuse>" >> template.dbt
echo "         <fileSize unit=\"KB\">2097152</fileSize>" >> template.dbt
echo "         <Thread>1</Thread>" >> template.dbt
echo "         <member ordinal=\"0\" memberName=\"redo04.log\" filepath=\"${DGREDO1^^}/${DBNAME^^}/\"/>" >> template.dbt
echo "      </RedoLogGroupAttributes>   " >> template.dbt
echo "   </StorageAttributes>" >> template.dbt
echo "</DatabaseTemplate>" >> template.dbt

echo -ne '-> Criando banco de dados......................\r\c'
local ERROR_MESSAGE="Erro ao criar banco de dados. Verifique o log para mais detalhes" #Cria mensagem amigavel 
echo -e "${ORACLE_HOME}/bin/dbca -silent -createDatabase -responseFile /dbs/tools/dbaops/dbagit/sh/db.rsp \n" >> $FULL_LOGFILE_DIR
trap "" SIGINT SIGQUIT SIGTSTP
#${ORACLE_HOME}/bin/dbca -silent -createDatabase -responseFile /dbs/tools/dbaops/dbagit/sh/db.rsp |tee $FULL_LOGFILE_DIR
trap - SIGINT SIGQUIT SIGTSTP
echo -ne '-> Criando banco de dados......................[OK]\r'
echo -ne '\n'

echo -e "\n####FINAL CRIACAO DO BANCO ${DBNAME} ####\n" >> $FULL_LOGFILE_DIR

} #FIM FN_CREATE_DB

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through time command and other functions
set -e           # terminate the script upon errors
#set -x          # debug mode

##CAPTURA SINAIS DE INTERRUPCAO
trap 'fn_exit_error $? $LINENO "$ERROR_MESSAGE"' ERR 1 3 9 15           #demais sinais de erro
trap 'fn_exit_ctrlc $? $LINENO' SIGINT SIGTSTP                          #ctrlc ou ctrlz
trap 'rm -f .db_oh_*  &>/dev/null' 0                                     #limpa temp files qd terminado

##invoke the argument function
ALLARGS=`echo "${@}" | sed -e 's/\xE2\x80\x94/-/g'`
fn_menu $ALLARGS
fn_inicializa
if [ "${shape}" == "list" ]; then 
fn_shape 
else
fn_create_db $oh $dbname $shape
fi;


##FIM DO SCRIPT