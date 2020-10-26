#! /usr/bin/env bash
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi

#roadmap
#adicionar alias de tools

if [ -d "/dbs/tools/dbaops" ]; then
  export WORKDIR="/dbs/tools"
  export DBAGIT=${WORKDIR}"/dbaops/dbagit"
  export SQLPATH=${DBAGIT}"/sql"
  export DBATOOLS=${WORKDIR}"/tools"
  export PATH=$PATH:${DBAGIT}"/sh"
elif [ -d "/oracle/admin/scripts/dbaops" ]; then
  export WORKDIR="/oracle/admin/scripts"
  export DBAGIT=${WORKDIR}"/dbaops/dbagit"
  export SQLPATH=${DBAGIT}"/sql"
  export DBATOOLS=${WORKDIR}"/tools"
  export PATH=$PATH:${DBAGIT}"/sh"
else
  echo -e "\nDiretorio WORKDIR=[/dbs/tools|/oracle/admin] nao detectado\n"
fi
export SCRIPTS="/oracle/admin/scripts"
export NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P15
export PS1="[""`uname -n`""-"'$ORACLE_SID'"]"'$PWD'"> "
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib:$ORACLE_HOME/network/jlib
export ASMSID=$(grep ^\+ASM /etc/oratab | cut -d ":" -f1)
export ASMHOME=$(grep ^\+ASM /etc/oratab | cut -d ":" -f2)
export OGG_HOME=$(grep ^\OGG /etc/oratab | cut -d ":" -f2)

update_oratab(){
for i in $(ps -ef | grep pmon | egrep -v "grep|APX|MGMTDB" | awk {' print $2 "|" substr($8,10) '}); do
local ORACLEPID=$(echo $i|cut -d"|" -f1)
local ORACLESID=$(echo $i|cut -d"|" -f2)
local ORACLEHOME=$(strings /proc/$ORACLEPID/environ |grep -i ORACLE_HOME|cut -d"=" -f2)
local ORATABROW=${ORACLESID}":"${ORACLEHOME}
##DB
if [ -f "/etc/oratab" ]; then
  #achou o oratab
  local ROWCOUNT=$(cat /etc/oratab |grep "^${ORATABROW}"|wc -l)
  if [ "$ROWCOUNT" -eq "0" ]; then
    #nao encontrou a linha 
	echo ${ORATABROW}":N" >> /etc/oratab
	echo ${ORATABROW}":N"
  fi;
fi
done;
##GOLDENGATE
local OGGHOME=$(agctl config goldengate 2>/dev/null $(crsctl stat res -t 2>/dev/null |grep goldengate |cut -d'.' -f2 ) |grep "GoldenGate location" |awk {' print $4 '} 2>/dev/null)
if [ ! -z "$OGGHOME"  ]; then 
  local ROWCOUNT=$(cat /etc/oratab |grep "^OGG:${OGGHOME}"|wc -l)
  if [ "$ROWCOUNT" -eq "0" ]; then
      #nao encontrou a linha 
	  echo "OGG:"${OGGHOME}":N" >> /etc/oratab
	  echo "OGG:"${OGGHOME}":N"
  fi;
fi;
}

db()
{
if [ -z "$1" ]; then
  ORATAB="/etc/oratab"
  #Set the prompt for the menu
  PS3=$'\n''Para qual banco deseja setar o ORACLE_SID? '
  select VAR in $( egrep '^[^#*]*:' $ORATAB | cut -d ':' -f 1 | sort ) "Manual Input"; do
  case $VAR in
    "Manual Input")
    echo
    echo "Escreva seu ORACLE_SID"
    read VAR2
    export ORACLE_SID=$VAR2
    echo "Escreva seu ORACLE_HOME"
    read VAR2
    export ORACLE_HOME=$VAR2
    break
  ;;
  "+ASM"*)
    export ORACLE_SID=${VAR}
    ORAENV_ASK=NO
    . oraenv 1>/dev/null <<EOF
$ORACLE_SID
EOF
    unset ORAENV_ASK
    break
  ;;
  *)
    export ORACLE_SID=${VAR}
    ORAENV_ASK=NO
    . oraenv 1>/dev/null <<EOF
$ORACLE_SID
EOF
    unset ORAENV_ASK
    break
  ;;
  esac
  done
else ##NAO FOI DEFINIDO VARIAVEL
  if [ "$1" == "orainstall" ]; then ##criado para a instalacao do jenkins
  export ORACLE_SID=${ASMSID}
  ORAENV_ASK=NO
  . oraenv 1>/dev/null <<EOF
$ORACLE_SID
EOF  
  unset ORAENV_ASK
  else
  export ORACLE_SID=${1}
  ORAENV_ASK=NO
  . oraenv 1>/dev/null <<EOF
$ORACLE_SID
EOF
  unset ORAENV_ASK
  fi;
  
fi;

#DESCOBRINDO O CAMINHO DO ALERT DO BANCO
if [ "${ORACLE_SID}" != "${ASMSID}" ]; then #EH BANCO
  if [ -w "/dbs/trace/diag/rdbms/$(echo ${ORACLE_SID} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log" ]; then
    #NAO EH RAC e esta no DBS/TRACE
    export ALERTDB="/dbs/trace/diag/rdbms/$(echo ${ORACLE_SID} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"
    export ALERTDBDIR="/dbs/trace/diag/rdbms/$(echo ${ORACLE_SID} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/"
  elif [ -w "/dbs/trace/diag/rdbms/$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"  ]; then
    #EH RAC TEM DE TIRAR INST_ID e esta no /DBS/TRACE
    export ALERTDB="/dbs/trace/diag/rdbms/$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"
    export ALERTDBDIR="/dbs/trace/diag/rdbms/$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/"
  elif [ -w "$ORACLE_BASE/diag/rdbms/$(echo ${ORACLE_SID} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log" ]; then
    #NAO EH RAC e esta no ORACLE_BASE
    export ALERTDB="$ORACLE_BASE/diag/rdbms/$(echo ${ORACLE_SID} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"
    export ALERTDBDIR="$ORACLE_BASE/diag/rdbms/$(echo ${ORACLE_SID} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/"
  elif [ -w "$ORACLE_BASE/diag/rdbms/$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"  ]; then
    #EH  RAC TEM DE TIRAR INST_ID e esta no ORACLE_BASE
    export ALERTDB="$ORACLE_BASE/diag/rdbms/$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"
    export ALERTDBDIR="$ORACLE_BASE/diag/rdbms/$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/"
  elif [ -w "$ORACLE_BASE/diag/rdbms/i$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"  ]; then
    #RAC CURITIBA, ADICIONA UM I
    export ALERTDB="$ORACLE_BASE/diag/rdbms/i$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"
    export ALERTDBDIR="$ORACLE_BASE/diag/rdbms/$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/"
  elif [ -w "$ORACLE_BASE/diag/rdbms/i$(echo ${ORACLE_SID} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"  ]; then
    #SINGLE CURITIBA, ADICIONA UM I
    export ALERTDB="$ORACLE_BASE/diag/rdbms/i$(echo ${ORACLE_SID} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"
    export ALERTDBDIR="$ORACLE_BASE/diag/rdbms/$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/"
  elif [ -w "$ORACLE_BASE/diag/rdbms/i$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"  ]; then
    #RAC CURITIBA, ADICIONA UM C
    export ALERTDB="$ORACLE_BASE/diag/rdbms/c$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"
    export ALERTDBDIR="$ORACLE_BASE/diag/rdbms/$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/"
  elif [ -w "$ORACLE_BASE/diag/rdbms/i$(echo ${ORACLE_SID} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"  ]; then
    #SINGLE CURITIBA, ADICIONA UM C
    export ALERTDB="$ORACLE_BASE/diag/rdbms/c$(echo ${ORACLE_SID} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"
    export ALERTDBDIR="$ORACLE_BASE/diag/rdbms/$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/"
  else #NAO ENCONTROU NADA
    export ALERTDB=""
    export ALERTDBDIR=""
  fi;
else #EH ASM
  if [ -w "/dbs/trace/diag/asm/$(echo ${ORACLE_SID} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log" ]; then
    #NAO EH RAC e esta no DBS/TRACE
    export ALERTDB="/dbs/trace/diag/asm/$(echo ${ORACLE_SID} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"
    export ALERTDBDIR="/dbs/trace/diag/asm/$(echo ${ORACLE_SID} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/"
  elif [ -w "/dbs/trace/diag/asm/$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"  ]; then
    #EH RAC TEM DE TIRAR INST_ID e esta no /DBS/TRACE
    export ALERTDB="/dbs/trace/diag/asm/$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"
    export ALERTDBDIR="/dbs/trace/diag/asm/$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/"
  elif [ -w "$ORACLE_BASE/diag/asm/$(echo ${ORACLE_SID} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log" ]; then
    #NAO EH RAC e esta no ORACLE_BASE
    export ALERTDB="$ORACLE_BASE/diag/asm/$(echo ${ORACLE_SID} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"
    export ALERTDBDIR="$ORACLE_BASE/diag/asm/$(echo ${ORACLE_SID} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/"
  elif [ -w "$ORACLE_BASE/diag/asm/$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"  ]; then
    #EH  RAC TEM DE TIRAR INST_ID e esta no ORACLE_BASE
    export ALERTDB="$ORACLE_BASE/diag/asm/$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/alert_$ORACLE_SID.log"
    export ALERTDBDIR="$ORACLE_BASE/diag/asm/$(echo ${ORACLE_SID:0:`expr ${#ORACLE_SID} - 1`} | tr '[A-Z]' '[a-z]')/$ORACLE_SID/trace/"
  else #NAO ENCONTROU NADA
    export ALERTDB=""
    export ALERTDBDIR=""
  fi;

fi;

#DESCOBRINDO O CAMINHO DO ALERT DO GRID
if [ -w "$ORACLE_BASE/diag/crs/$(echo ${HOSTNAME}|awk {' gsub(".redecorp.br","",$0); print '}| tr '[A-Z]' '[a-z]')/crs/trace/alert.log" ]; then
  #12C
  export ALERTCLU="$ORACLE_BASE/diag/crs/$(echo ${HOSTNAME}|awk {' gsub(".redecorp.br","",$0); print '}| tr '[A-Z]' '[a-z]')/crs/trace/alert.log"
  export ALERTCLUDIR="$ORACLE_BASE/diag/crs/$(echo ${HOSTNAME}|awk {' gsub(".redecorp.br","",$0); print '}| tr '[A-Z]' '[a-z]')/crs/trace"
elif [ -w "$ASMHOME/log/$(echo ${HOSTNAME}| tr '[A-Z]' '[a-z]')/alert$(echo ${HOSTNAME}| tr '[A-Z]' '[a-z]').log" ]; then
  ##11G
  export ALERTCLU="$ASMHOME/log/$(echo ${HOSTNAME}| tr '[A-Z]' '[a-z]')/alert$(echo ${HOSTNAME}| tr '[A-Z]' '[a-z]').log"
  export ALERTCLUDIR="$ASMHOME/log/$(echo ${HOSTNAME}| tr '[A-Z]' '[a-z]')"
fi;
export PATH=$PATH:${ASMHOME}"/bin"
echo -e "\nORACLE_HOME="$ORACLE_HOME
echo -e "ORACLE_SID="$ORACLE_SID"\n"
#echo -e "ASMHOME="$ASMHOME"\n"
}

profileping(){
  echo "pong"
}

showconfig(){
if ( [ -z "$1" ] && [ "$ORACLE_SID" ] ); then
  local DB=$(echo $ORACLE_SID | tr '[:upper:]' '[:lower:]') ##transforma para lowercase
elif ( [ -z "$1" ] && [ -z "$ORACLE_SID" ] ); then
  echo -e "\nNecessario setar variavel ORACLE_SID\n"
else 
  local DB=$(echo $1 | tr '[:upper:]' '[:lower:]') ##transforma para lowercase
fi;
if [ "${DB}" ]; then
  local HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://10.240.42.99:9080/automacao/banco_de_dados/dbagit/raw/master/util/env/env_${DB})
  if [ "${HTTP_CODE}" -eq "404" ]; then
    echo -e "\nNenhuma configuracao encontrada para ${DB}"
  else
    curl http://10.240.42.99:9080/automacao/banco_de_dados/dbagit/raw/master/util/env/env_${DB}
  fi;
  unset DB
  echo -e "\n"
fi;  
}

dbhanganalyze(){
if [ -z "$ORACLE_SID" ]; then
  echo -e "\nNecessario setar variaveis de banco\n"
else
  if ( [ -n "$1" ] && [ "$1" == "prelim" ] ); then
echo -e "\n--> Executando sqlplus -prelim / as sysdba oradebug hanganalyze 3 no banco "$ORACLE_SID"\n"
sqlplus -prelim -s / as sysdba <<EOF
set feedback off
oradebug setmypid
oradebug unlimit
oradebug hanganalyze 3    
prompt
prompt --> Aguardando 10 segundos
exec DBMS_LOCK.SLEEP(10);
oradebug hanganalyze 3
prompt
prompt --> Aguardando 10 segundos
exec DBMS_LOCK.SLEEP(10);
EOF

  else
echo -e "\n--> Executando sqlplus / as sysdba oradebug hanganalyze 3 no banco "$ORACLE_SID"\n"
sqlplus -s / as sysdba <<EOF
oradebug setmypid
oradebug unlimit
oradebug hanganalyze 3    
prompt
prompt --> Aguardando 10 segundos
exec DBMS_LOCK.SLEEP(10);
oradebug hanganalyze 3
prompt
prompt --> Aguardando 10 segundos
exec DBMS_LOCK.SLEEP(10);
EOF

  fi;
fi;

}

logstat(){
  echo ""
  printf "%-20s %-20s\n" "" "ULTIMA ATUALIZACAO"
  printf "%-20s %-20s\n" " " "--------------------"
  printf "%-20s %-20s\n" "ALERTDB" "$(stat -c "%z" "$ALERTDB" 2>/dev/null)"
  printf "%-20s %-20s\n" "ALERTCLU" "$(stat -c "%z" "$ALERTCLU" 2>/dev/null)"
  printf "%-20s %-20s\n" "GITSYNC" "$(stat -c "%z" "$DBAGIT/.git/FETCH_HEAD" 2>/dev/null)"
  echo ""
}

dbalias(){
echo -e "\n#######################################################"
echo -e "-> ENVIRONMENT VARs:"
echo -e "#######################################################"
printf "\n%-15s = %-20s\n" "ORACLE_HOME" ${ORACLE_HOME}
printf "%-15s = %-20s\n" "ORACLE_SID" ${ORACLE_SID}
printf "%-15s = %-20s\n" "ALERTDB" ${ALERTDB}
printf "%-15s = %-20s\n" "ALERTDBDIR" ${ALERTDBDIR}
printf "%-15s = %-20s\n" "DBAGIT" ${DBAGIT}
printf "%-15s = %-20s\n" "SCRIPTS" ${SCRIPTS}
printf "%-15s = %-20s\n" "SQLPATH" ${SQLPATH}
printf "%-15s = %-20s\n" "DBATOOLS" ${DBATOOLS}
printf "%-15s = %-20s\n" "NLS_LANG" ${NLS_LANG}
printf "%-15s = %-20s\n" "ASMSID" ${ASMSID}
printf "%-15s = %-20s\n" "ASMHOME" ${ASMHOME}
printf "%-15s = %-20s\n" "ALERTCLU" ${ALERTCLU}
printf "%-15s = %-20s\n" "ALERTCLUDIR" ${ALERTCLUDIR}
logstat
echo -e "#######################################################"
echo -e "-> FERRAMENTAS:"
echo -e "#######################################################\n"
echo -e "- db              : Define variaveis de ambiente Oracle. EXEMPLO: db <ORACLE_SID> "
echo -e "- update_oratab   : Atualiza arquivo oratab com bancos e Goldengates ativos"
echo -e "- showconfig      : Exibe configuracao detalhada do ambiente. EXEMPLO: showconfig <DB_NAME>"
echo -e "- dbalias         : Exibe os comandos e alias disponiveis"
echo -e "- dbhanganalyze   : Executa comando de hanganalyze, pode ser usado com base baixada usando prelim. EXEMPLO: dbhanganalyze <prelim>"
echo -e "- sqlindex        : Exibe o indice dos SQLs disponiveis no SQLPATH"
echo -e "- alertdb         : Executa um tail -50f no alert do banco ou asm"
echo -e "- alertclu        : Executa um tail -50f no alert do cluster"
echo -e "- gg              : Abre Goldengate command line"
echo -e "- crq             : Abre diretorio com scripts de CRQ\n"
}

###########ALIAS##########
alias alertdb='tail -500f $ALERTDB'
alias alertdbdir='cd  $ALERTDBDIR'
alias alertclu='tail -500f $ALERTCLU'
alias alertcludir='cd $ALERTCLUDIR'
alias dbatools="cd $DBATOOLS"
alias sqldba='sqlplus '\''/ as sysdba'\'''
alias sqlasm='sqlplus '\''/ as sysasm'\'''
alias ll='ls -ltr'
alias lla='ls -ltra'
alias crq='cd $WORKDIR/crq'
alias pm="ps -ef | grep -i pmon | grep -v "$$""
alias pt="ps -ef | grep -i tns | grep -v "$$""
alias sqlindex="grep -i 'Description  :' $SQLPATH/*.sql | awk -v sqlpath=$SQLPATH -F: '{ gsub(sqlpath\"/\",\"\",\$1); printf(\"%50s %-50s\n\", \$1, \$3) }'"
alias gg='$OGG_HOME/ggsci'
alias ggh='cd $OGG_HOME'
alias gglog='tail -50f $OGG_HOME/ggserr.log'
alias gitsync='cd $DBAGIT;git pull dbagit master'
alias gitclean='cd $DBAGIT;git clean -f'

stty erase "^H"