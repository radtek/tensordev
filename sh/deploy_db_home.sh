#! /usr/bin/env bash
##teste de alteracao
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

ARGUSAGE="MODO DE USO: $(basename $0) -ohname [OH_NAME] -ohfolder <ORACLE_HOME> -patchid [PATCHID] -list [local|repo] -ref [#ticket remedy] -dryrun -h

EXEMPLO: $(basename $0) -ohname ORA_19_5_2043212 -ohfolder /u01/app/oracle/product/19.5.0.0/dbhome_1 -patchid 2
         Instala um novo ORACLE_HOME chamado ORA_19_5_2043212 no diretorio /u01/app/oracle/product/19.5.0.0/dbhome_1

  -ohname
      Define um nome para para o ORACLE_HOME
      Parametro obrigatório 
  -ohfolder
      Especifica um diretorio para o ORACLE_HOME
      Parametro obrigatório
  -patchid
      Especifica a imagem a ser instalada no servidor. Para mais informações execute $(basename $0) -list repo 
      Parametro obrigatório
  -list
      Lista ORACLE_HOMEs:
      local     - Exibe ORACLE_HOMEs instalados no servidor
      repo - Exibe versoes de ORACLE_HOME disponiveis para instalacao
  -ref
      Numero da requisicao ou ticket no remedy
  -dryrun
      Somente faz uma checagem sem modificar nada
  -h ou -help
      Mostra as opções de ajuda
"
	
	while [ "$1" != "" ]
	do
	    case $1 in
  -ohname) ohname=$2 ;
			if [ ! -z "$ohname" ] ; then
				shift 2
			else
        trap - ERR
				echo -e "\nERROR: Nenhum valor fornecido para o parametro -ohname\n"
				exit 1
			fi
			;;
  -list) list=$2 ;
			if [ ! -z "$list" ] ; then
				shift 2
			else
        trap - ERR
				echo -e "\nERROR: Nenhum valor fornecido para o parametro -list\n"
				exit 1
			fi
			;;
  -ohfolder) ohfolder=$2 ;
			if [ ! -z "$ohfolder" ] ; then
				shift 2
			else
        trap - ERR
        echo -e "\nERROR: Nenhum valor fornecido para o parametro -ohfolder\n"
				exit 1
			fi			
			;;
  -patchid) patchid=$2 ;
			if [ ! -z "$patchid" ] ; then
				shift 2
			else
        trap - ERR
				echo -e "\nERROR: Nenhum valor fornecido para o parametro -patchid\n"
				exit 1
			fi
			;;
  -ref) wo=$2 ;
			if [ ! -z "$wo" ] ; then
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

if [ -z "$list" ]; then
  if  [ -z "$ohname" ]; then 
      trap - ERR
  		echo -e "\nERROR: ohname nao especificado. Use opcao -h para ajuda\n"
  		exit 1
  elif  [ -z "$ohfolder" ]; then 
      trap - ERR
  		echo -e "\nERROR: ohfolder nao especificado. Use opcao -h para ajuda\n"
  		exit 1
  elif  [ -z "$patchid" ]; then 
      trap - ERR
  		echo -e "\nERROR: patchid nao especificado. Use opcao -h para ajuda\n"
  		exit 1
  fi	
fi;


}


fn_list_home(){
##lista patches instalados ou disponiveis
#USAGE:
#deploy_db_home.sh -list repo 
#deploy_db_home.sh -list local

if [ "$1" == 'repo' ]; then #busca a lista de OH disponiveis no repo do GIT
  local ERROR_MESSAGE="Nao foi possivel ler o arquivo do GIT" #Cria mensagem amigavel 
  wget http://10.240.42.99:9080/automacao/banco_de_dados/dbagit/raw/master/sh/.db_oh_disponiveis &>/dev/null
  echo -e "\nLista de patches disponiveis para download:"
  printf "\n%- 10s %- 30s%-20s %-10s %-90s %s\n" "PATCHID" "PATCHNAME" "CREATED" "DBVERSION" "URL"
  echo "---------- ----------------------------- -------------------- ---------- ------------------------------------------------------------------------------------"
  for row in $(cat .db_oh_disponiveis |grep -v "#")
  do
  local PATCHID=$(echo $row|cut -d ',' -f1)
  local PATCHNAME=$(echo $row|cut -d ',' -f2)
  local PATCHCREATED=$(echo $row|cut -d ',' -f3)
  local PATCHURL=$(echo $row|cut -d ',' -f4)
  local PATCHDBVERSION=$(echo $row|cut -d ',' -f5)
  printf "%- 10s %- 30s%-20s %-10s %-90s %s\n" "$PATCHID" "$PATCHNAME" "$PATCHCREATED" "$PATCHDBVERSION" "$PATCHURL"
  done;
  echo -e "\n"
elif [ "$1" == 'local' ]; then #lista OH instalados no servidor
 local ERROR_MESSAGE="Nao foi possivel ler o arquivo inventory.xml" #Cria mensagem amigavel 
 local INV_LOC=$(cat /etc/oraInst.loc |grep -i inventory|cut -d'=' -f2)"/ContentsXML/inventory.xml"
 echo -e "\nINVENTARIO: ${INV_LOC}"
 echo -e "\nLista de produtos instalados neste servidor ${HOSTNAME}:" 
 printf "\n%- 25s %- 50s%-25s %s\n" "OH_NAME" "ORACLE_HOME"
 echo "------------------------- ----------------------------------------"
 for row in $(cat $INV_LOC|grep "<HOME NAME" |grep -v "REMOVED" |awk {' print $2","$3 '})
 do
   #echo $row
   local OH_NAME=$(echo $row|cut -d',' -f1|cut -d'=' -f2|sed -e "s/\"//g")
   local OH=$(echo $row|cut -d',' -f2|cut -d'=' -f2|sed -e "s/\"//g")
   printf "%- 25s %- 50s%-25s %s\n" "$OH_NAME" "$OH"
 done;
 echo -e "\n"
fi;
}

fn_add_home(){
local OH_NAME=$1
local OH_FOLDER_NAME=$2
local PATCHID=$3
#USAGE:
#./deploy_db_home.sh -ohname=BASE11204_7 -ohfolder=/u01/app/oracle/product/19.6.0.0/dbhome_1 -patchid=3
echo -e "\n####VALIDANDO PREREQs PARA INSTALACAO####\n"
#CHECK PREREQS - Diretorio
if [ ! -d "$OH_FOLDER_NAME"  ]; then                                             #cria pasta do OH
  echo -ne '-> Criando diretorio do OH.....................\r\c'
  mkdir -p $OH_FOLDER_NAME 
  echo -ne '-> Criando diretorio do OH.....................[OK]\r'
  echo -ne '\n'
  if [ $? -gt 0 ]; then                                                            #algum erro de permissão no diretorio
    fn_exit_error "1" "$LINENO" "Nao foi possivel criar o diretorio para o OH $OH_FOLDER_NAME"
  fi;
else 
  if [ $(ls $OH_FOLDER_NAME|wc -l) -gt "0" ]; then                                 #verifica se ja contem arquivos
    fn_exit_error "1" "$LINENO" "Diretorio $OH_FOLDER_NAME ja contem arquivos"
  #elif [ -d "$OH_FOLDER_NAME"  ]; then                                             #OH ja existe
  #  fn_exit_error "1" "$LINENO" "Diretorio $OH_FOLDER_NAME ja existe no servidor"
  fi;
fi;

#CHECK PREREQS - Espaço
MANOBRA_FREE_SPACE=$(df -Pk /dbs/manobra |grep -v "Filesystem" |awk {' print $4 '})
OH_FREE_SPACE=$(df -Pk $OH_FOLDER_NAME |grep -v "Filesystem" |awk {' print $4 '})
OH_MOUNTPOINT=$(df -Pk $OH_FOLDER_NAME |grep -v "Filesystem" |awk {' print $6 '})
if [ "$OH_FREE_SPACE" -lt "10485760" ]; then                                        #se tiver menos que 10GB livre no OH
  fn_exit_error "1" "$LINENO" "Nao ha espaco suficiente no filesystem para descompactar o instalador(10GB)"
else
  echo -ne '-> Checando espaço livre no filesystem.........\r\c'
  sleep 2
  echo -ne '-> Checando espaço livre no filesystem.........[OK]\r'
  echo -ne '\n'
fi;
if [ "$OH_MOUNTPOINT" == '/' ]; then                                             #mountpoint nao pode ser o /
  fn_exit_error "1" "$LINENO" "Mountpoint nao pode ser o /"
else
  echo -ne '-> Checando mountpoint diferente de /..........\r\c'
  sleep 2
  echo -ne '-> Checando mountpoint diferente de /..........[OK]\r'
  echo -ne '\n'
fi;
if [ "$MANOBRA_FREE_SPACE" -lt "5242880" ]; then                                  #se staging filessytem for menor que 5GB
  fn_exit_error "1" "$LINENO" "Nao ha espaco suficiente no /dbs/manobra para o download do instalador(5GB)"
else
  echo -ne '-> Checando espaço /dbs/manobra................\r\c'
  sleep 2
  echo -ne '-> Checando espaço /dbs/manobra................[OK]\r'
  echo -ne '\n'
fi;


#CHECK PREREQS - Imagem do OH
local ERROR_MESSAGE="Nao foi possivel ler o arquivo do GIT" #Cria mensagem amigavel 
wget http://10.240.42.99:9080/automacao/banco_de_dados/dbagit/raw/master/sh/.db_oh_disponiveis &>/dev/null
local ERROR_MESSAGE="PATCHID invalido, para mais informações use o comando $(basename $0) -list repo " #Cria mensagem amigavel 
PATCHINFO=$(cat .db_oh_disponiveis |grep -v "#"|grep ^$PATCHID,)
PATCHURL=$(echo $PATCHINFO|cut -d ',' -f4)
PATCHFILE=$(echo $PATCHURL|cut -d '/' -f7)
PATCHDBVERSION=$(echo $PATCHINFO|cut -d ',' -f5)
local ERROR_MESSAGE="Nao foi possivel obter URL para download" #Cria mensagem amigavel 
wget --spider $PATCHURL &>/dev/null

##Verifica se eh dryrun
if [ $dryrun ]; then ##remove o diretorio se for dryrun
  rmdir $OH_FOLDER_NAME
  echo -e "\nSUCCESS: Nenhum problema encontrado para o deploy do HOME -> $OH_FOLDER_NAME\n"
  exit 0
else

echo -e "\n--------------------------------------------------------------------------------------------------"
echo "|                                        RESUMO DA INSTALACAO                                    |"
echo "--------------------------------------------------------------------------------------------------"
printf "| %-12s %-15s || %-10s %-50s%s |\n" "OH_MOUNTPOINT" $OH_MOUNTPOINT "OH_FOLDER" $ohfolder
printf "| %-12s %-15s || %-10s %-50s%s |\n" "MANOBRA_SPACE" $MANOBRA_FREE_SPACE "OH_NAME" $ohname
printf "| %-12s %-15s || %-10s %-50s%s |\n" "OH_FREE_SPACE" $OH_FREE_SPACE "PATCHID" "$PATCHID"
echo -e "--------------------------------------------------------------------------------------------------\n"


#printa confirmação antes de prosseguir
while true; do
    read -p "Um novo ORACLE_HOME será instalado neste servidor. Deseja prosseguir? [Ss|Nn]" yn
    case $yn in
        [Ss]* ) break;;
        [Nn]* ) echo -e "\n>>ENCERRANDO SCRIPT<<\n"; exit;;
        * ) echo "Por favor responda sim ou nao.";;
    esac
done

#INICIA A INSTALACAO
echo -e "\nLOG COMPLETO: $FULL_LOGFILE_DIR "
echo -e "\n####INICIANDO INSTALACAO DO OH $OH_FOLDER_NAME ####\n"

echo -ne '-> Fazendo download da imagem.........\r\c' 
local ERROR_MESSAGE="Problema ao fazer download da imagem" #Cria mensagem amigavel 
wget -O /dbs/manobra/$PATCHFILE $PATCHURL &>> $FULL_LOGFILE_DIR
if [ "$?" -gt 0 ] || [ ! -r  "/dbs/manobra/"$PATCHFILE ];then
  fn_exit_error "1" "$LINENO" "Encontrado problema com o arquivo da imagem /dbs/manobra/"$PATCHFILE
fi;
echo -ne '-> Fazendo download da imagem.........[OK]\r'
echo -ne '\n'

echo -ne '-> Descompactando arquivos............\r\c' 
local ERROR_MESSAGE="Erro encontrado ao descompactar arquivos" #Cria mensagem amigavel 
unzip -o "/dbs/manobra/"$PATCHFILE -d $OH_FOLDER_NAME &>> $FULL_LOGFILE_DIR
echo -ne '-> Descompactando arquivos............[OK]\r'
echo -ne '\n'
if [ "$?" -gt 0 ] || [ ! -r  "/dbs/manobra/"$PATCHFILE ];then
  fn_exit_error "1" "$LINENO" "Encontrado problema com o arquivo da imagem /dbs/manobra/"$PATCHFILE
fi;

echo -ne '-> Clonando instalacao................\r\c' 
trap "" SIGINT SIGTSTP
if [ "$PATCHDBVERSION" == '12c' ]; then
  #12c
  $OH_FOLDER_NAME/perl/bin/perl $OH_FOLDER_NAME/clone/bin/clone.pl ORACLE_BASE="/u01/app/oracle" ORACLE_HOME="$OH_FOLDER_NAME" OSDBA_GROUP=dba OSOPER_GROUP=oper OSBACKUPDBA_GROUP=dba OSRACDBA_GROUP=dba ORACLE_HOME_NAME=$OH_NAME |tee -a $FULL_LOGFILE_DIR
elif [ "$PATCHDBVERSION" == '19c' ]; then
  #19c
  $OH_FOLDER_NAME/runInstaller -silent -waitForCompletion -force oracle.install.option=INSTALL_DB_SWONLY UNIX_GROUP_NAME=oinstall ORACLE_HOME=$OH_FOLDER_NAME ORACLE_HOME_NAME=$OH_NAME ORACLE_BASE=/u01/app/oracle oracle.install.db.InstallEdition=EE oracle.install.db.DBA_GROUP=dba oracle.install.db.OPER_GROUP=oper oracle.install.db.OSBACKUPDBA_GROUP=dba oracle.install.db.OSDGDBA_GROUP=dba oracle.install.db.OSKMDBA_GROUP=dba oracle.install.db.OSRACDBA_GROUP=dba DECLINE_SECURITY_UPDATES=true |tee -a $FULL_LOGFILE_DIR
fi;
trap - SIGINT SIGQUIT SIGTSTP
echo -ne '-> Clonando instalacao................[OK]\r'
echo -ne '\n'

echo -ne '-> Habilitando RAC....................\r\c' |tee -a $FULL_LOGFILE_DIR
export ORACLE_HOME=$OH_FOLDER_NAME
cd $ORACLE_HOME/rdbms/lib
make -f ins_rdbms.mk rac_on ioracle >> $FULL_LOGFILE_DIR
cd -
echo -ne '-> Habilitando RAC....................[OK]\r'
echo -ne '\n'

echo -e "\nWARNING: Por favor execute o script como usuario root -> ${ORACLE_HOME}/root.sh "
echo -e "\nSUCCESS: Criado novo HOME $OH_NAME com diretorio $OH_FOLDER_NAME no servidor ${HOSTNAME}\n"
fi;

}

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through time command and other functions
set -e           # terminate the script upon errors
#set -x          # debug mode

##CAPTURA SINAIS DE INTERRUPCAO
trap 'fn_exit_error $? $LINENO "$ERROR_MESSAGE"' ERR 1 3 9 15           #demais sinais de erro
trap 'fn_exit_ctrlc $? $LINENO' SIGINT SIGTSTP                          #ctrlc ou ctrlz
trap 'rm -f .db_oh_* &>/dev/null' 0                                     #limpa temp files qd terminado

##invoke the argument function
ALLARGS=`echo "${@}" | sed -e 's/\xE2\x80\x94/-/g'`
fn_menu $ALLARGS
fn_inicializa

#BODY
#echo $ohname
#echo $ohfolder
#echo $patchid
#echo $list
#echo $wo
#echo $dryrun
if [ $list ]; then
  fn_list_home $list
else
  fn_add_home $ohname $ohfolder $patchid
fi;

##FIM DO SCRIPT