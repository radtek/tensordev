#! /usr/bin/env bash
#conf_db_tablespace.sh
#Objetivo: Gerenciamento de tablespaces, cria, adiciona ou faz resize de datafiles
# -> REVISOES
#    19/11/2019  -  Criacao                                                     -   jose.juliano@telefonica.com

##ROADMAP
#Verificar DG diferente em caso de resize
#alguns servidores travam quando executamos queries nas v$

##Verifica se WORKDIR está criado, senao sai do script
#VOLTAR
#  if [ -d "/dbs/tools/" ]; then
#    WORKDIR="/dbs/tools"
#  elif [ -d "/oracle/admin" ]; then
#    WORKDIR="/oracle/admin"
#  else
#    echo -e "\nERROR: Nao foi possivel detectar diretorio WORKDIR. Verifique se /dbs/tools ou /oracle/admin estao criados no servidor\n"
#    exit 1
#  fi

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

fn_cleanup()
{
  $(rm .cfgtbs_* 2>/dev/null)
}

fn_debug()
{
  COL1=$1
  echo $COL1
  read -p "<Aperte enter para continuar>"
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

  ##Cria cabecalho do arquivo csv
  #VOLTAR
  #echo "SERVIDOR|SECAO|SUBSECAO|CHAVE|VALOR|SCORE" > $FULL_OUTPUT_DIR.csv
  
  
}

fn_menu() {

ARGUSAGE="MODO DE USO: $(basename $0) -db <INSTANCE_NAME> -tbs <TABLESPACE_NAME> -inc <INCIDENT#> -checkOnly -size SIZE[GB] -h

EXEMPLO: $(basename $0) -db PROD1 -tbslimit 70
         Verifica todos os tablespaces com threshould de uso em 70% e faz crescimento do tablespace

  -db
      Nome da instancia onde sera adicionado espaço no tablespace
      Parametro obrigatório
  -tbslimit
      Valor de 50 a 99 para threshold de verificação de espaço livre nos tablespaces
      Default é 80%
  -tbs
      Nome do tablespace
      Parametro obrigatório
  -size
      Valor em GB a ser adicionado.
      Por default será calculado threshold para 80% de ocupação.
  -inc
      Numero do incidente no remedy
  -dg
      Especifica o diskgroup onde os tablespaces serão adicionados
  -checkonly
      Somente faz uma checagem sem adicionar o espaço
  -h
      Mostra as opções de ajuda
"
	
	while [ "$1" != "" ]
	do
	    case $1 in
  -db) db=$2 ;
			if [ ! -z "$db" ] ; then
				shift 2
			else
        trap - ERR
				echo -e "\nERROR: Nenhum valor fornecido para o parametro -db\n"
				exit 1
			fi
			;;
  -tbs) tbs=$2 ;
			if [ ! -z "$tbs" ] ; then
				shift 2
			else
        trap - ERR
				echo -e "\nERROR: Nenhum valor fornecido para o parametro -tbs\n"
				exit 1
			fi
			;;
  -size) size=$2 ;
			if [ ! -z "$size" ] ; then
				shift 2
			else
        trap - ERR
        echo -e "\nERROR: Nenhum valor fornecido para o parametro -size\n"
				exit 1
			fi			
			;;
  -inc) incident=$2 ;
			if [ ! -z "$incident" ] ; then
				shift 2
			else
        trap - ERR
				echo -e "\nERROR: Nenhum valor fornecido para o parametro -inc\n"
				exit 1
			fi
			;;
  -tbslimit) tbslimit=$2 ;
			if [ ! -z "$tbslimit" ] ; then
				shift 2
			else 
        trap - ERR
				echo -e "\nERROR: Nenhum valor fornecido para o parametro -tbslimit\n"
				exit 1
			fi
			;;
  -check) check=$2;##PROBLEMA AQUI
      if [ ! -z "$check" ] ; then
				shift 2
			else
        check="n"
			fi
			;;			
  -h) 
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
if ( [ -z "$tbslimit" ] ); then 
		tbslimit=80
elif ( [ "$tbslimit" -lt "30" ]  || [ "$tbslimit" -gt "99" ] ) ; then
    trap - ERR
    echo -e "\nERROR: Valor de -tbslimit deve ser entre 50 e 99\n"
		exit 0
fi

if ( [ -z "$db" ] ); then 
    trap - ERR
		echo -e "\nERROR: Banco ou nome do tablespace não especificados. Use opcao -h para ajuda\n"
		exit 1
fi	
}

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through time command and other functions
set -e           # terminate the script upon errors
#set -x          # debug mode

##CAPTURA SINAIS DE INTERRUPCAO
trap 'fn_handle_error $? $LINENO' ERR 1 3 9 15           #demais sinais de erro
trap 'fn_handle_ctrlc $? $LINENO' SIGINT SIGTSTP         #ctrlc ou ctrlz
trap 'rm .cfgtbs_* 2>/dev/null' 0                        #limpa temp files qd terminado

##invoke the argument function
ALLARGS=`echo "${@}" | sed -e 's/\xE2\x80\x94/-/g'`
fn_menu $ALLARGS
##Inicializa arquivos e diretorios
fn_inicializa

echo -e "\n                STARTING TABLESPACE CONFIG    $(date)  \n"

#echo "db: "${db}
#echo "tbs: "${tbs}
#echo "inc: "${incident}
#echo "checkonly: "${checkonly}
#echo "tbslimit: "${tbslimit}

##VARs
ORACLE_SID=${db}
ORACLE_USER=$(ps -ef | grep pmon | grep ${db} | grep -v grep | grep -v ASM | awk '{ print $1 }')
ORAENV_ASK=NO
. oraenv 1>/dev/null <<EOF
$ORACLE_SID
EOF


#verifica qual o DG de dados com maior espaço livre
sqlplus -s / as sysdba <<EOF > .cfgtbs_dg_$ORACLE_SID
set head off
set feedback off
select name||'|'|| --dg_name
decode(type,'NORMAL',round((free_mb)/2,2),'HIGH',round((free_mb)/3,2),'EXTERN',round(free_mb,2))||'|'|| --real_free_mb
decode(type,'NORMAL',round((total_mb)/2,2),'HIGH',round((total_mb)/3,2),'EXTERN',round(total_mb,2)) --real_total_space
from v\$asm_diskgroup
where free_mb=(select max(free_mb) 
from v\$asm_diskgroup 
where name like '%DATA%')
and name like '%DATA%';
EOF

dg_name=$(cat .cfgtbs_dg_$ORACLE_SID| cut -d'|' -f1|tr -d '\n')
dg_free_mb=$(cat .cfgtbs_dg_$ORACLE_SID| cut -d'|' -f2|tr -d '\n')
dg_total_space=$(cat .cfgtbs_dg_$ORACLE_SID| cut -d'|' -f3|tr -d '\n')
dtfsize="32767"

#Verifica se ha tablespace para crescer
sqlplus -s / as sysdba <<EOF > .cfgtbs_tbstotal_$ORACLE_SID
set head off
set feedback off
set lines 200
select
tbsname||'|'||
size_mb||'|'||
(CASE when (nvl(size_to_add,0)-nvl(size_to_resize,0)) < 0 then '0' else to_char( ceil(nvl(size_to_add,0)-nvl(size_to_resize,0)) ) END)||'|'|| --size_to_add
(CASE when (nvl(size_to_add,0)-nvl(size_to_resize,0)) < 0 then '0' else to_char(ceil((nvl(size_to_add,0)-nvl(size_to_resize,0))/32767))  END)||'|'|| --qtd_to_add
size_to_resize||'|'||
qtd_to_resize||'|'||
ceil(size_to_add)||'|'|| --total a adicionar
free_mb
from (
select tsu.tablespace_name tbsname
,ceil(tsu.used_mb) size_mb
,to_char(ceil((tsu.used_mb - tsf.free_mb) / ($tbslimit/100)) - tsu.used_mb ) size_to_add
,(nvl(dtfree.freesize,0)/1024/1024) size_to_resize
,nvl(dtfree.qtd_dtfs,0) qtd_to_resize
,ceil(tsf.free_mb) free_mb
from 
 (select tablespace_name, sum(bytes)/1024/1024 used_mb
 from dba_data_files where tablespace_name not like 'UNDO%' group by tablespace_name
 ) tsu
, (select ts.tablespace_name,nvl(sum(bytes)/1024/1024, 0) free_mb
 from dba_tablespaces ts, dba_free_space fs
 where ts.tablespace_name = fs.tablespace_name (+)
 and ts.tablespace_name not like 'UNDO%'
 and bigfile='NO'
 group by ts.tablespace_name
 ) tsf
,(select tablespace_name,sum(34358689792-bytes) freesize,count(file_name) qtd_dtfs
from dba_data_files 
where bytes<34358689792
and tablespace_name not like 'UNDO%'
group by tablespace_name
) dtfree
where tsu.tablespace_name = tsf.tablespace_name (+)
  and tsu.tablespace_name = dtfree.tablespace_name (+)
  and 100 - (tsf.free_mb/tsu.used_mb)*100 >= $tbslimit
  and tsf.free_mb < 100000
);
EOF

for row in $(cat .cfgtbs_tbstotal_$ORACLE_SID)
do
  #let i++
  i=$((i+1))
  tbs_name[${i}]=$(echo $row|cut -d'|' -f1 |tr -d '\n')        #nome do tablespace
  tbs_size[${i}]=$(echo $row|cut -d'|' -f2 |tr -d '\n')        #tamanho do tablespace
  space_to_add[${i}]=$(echo $row|cut -d'|' -f3 |tr -d '\n')    #espaço a ser adicionado. Se for 0 entao o resize comporta todo valor
  dtfs_to_add[${i}]=$(echo $row|cut -d'|' -f4 |tr -d '\n')     #qtd datafiles a serem adicionados. Se for 0 entao o resize comporta todo valor
  space_to_resize[${i}]=$(echo $row|cut -d'|' -f5 |tr -d '\n') #espaço a ser redimensionado
  dtfs_to_resize[${i}]=$(echo $row|cut -d'|' -f6 |tr -d '\n')  #qtd datafiles para resize
  total_space[${i}]=$(echo $row|cut -d'|' -f7 |tr -d '\n')     #total de espaço necessario para threshold
  size_total_tbs=$(awk -v size_total_tbs="${size_total_tbs}" -v total_space="${total_space[$i]}" 'BEGIN{print (size_total_tbs+total_space)}')
done
current_dg_free_percent=$(awk -v dg_total_space="${dg_total_space}" -v size_total_tbs="${size_total_tbs}" -v dg_free_mb="${dg_free_mb}" 'BEGIN{ printf("%.f\n", (dg_free_mb/dg_total_space)*100 ) }')
later_dg_free_percent=$(awk -v dg_total_space="${dg_total_space}" -v size_total_tbs="${size_total_tbs}" -v dg_free_mb="${dg_free_mb}" 'BEGIN{ printf("%.f\n", ((dg_free_mb-size_total_tbs)/dg_total_space)*100 ) }')


#echo -e "\ndg_name="${dg_name}" dg_free_mb="${dg_free_mb}" dg_total_space="${dg_total_space}"\n"
#echo "size_total_tbs="${size_total_tbs}                        #soma em mb de espaço necessario para todos tablespaces encontrados
#echo "later_dg_free_percent="${later_dg_free_percent}          #%de espaço livre depois de adicionar espaço desejado
#echo "current_dg_free_percent="${current_dg_free_percent}      #%de espaço livre atual
#echo "Qtd tablespaces="${#tbs_name[@]}                         #Qtd de tablespaces encontrado


#SUMMARY
echo "------------------------------------------------------------------------------------------"
echo "|                                        SUMMARY                                         |"
echo "------------------------------------------------------------------------------------------"
printf "| %-20s %-20s || %-20s %-20s%s |\n" "DG de Dados" ${dg_name} "%Threshold TBS" ${tbslimit}
printf "| %-20s %-20s || %-20s %-20s%s |\n" "DG Total MB" ${dg_total_space} "DG Free MB" ${dg_free_mb}
printf "| %-20s %-20s || %-20s %-20s%s |\n" "Current DG Free%" ${current_dg_free_percent} "Later DG Free%" ${later_dg_free_percent}
printf "| %-20s %-20s || %-20s %-20s%s |\n" "Total a crescer(MB)" "${size_total_tbs}" "Qtd tablespaces" ${#tbs_name[@]}
echo "------------------------------------------------------------------------------------------"


#Verifica se o DG vai comportar o crescimento necessario, se < 10% entao nao prossegue
if [ "${later_dg_free_percent}" -le "10" ]; then
  echo -e "\nERROR: Espaco livre no diskgroup "${dg_name}" menor que 10%\n"
  #fn_cleanup
  exit 1
else
  if [ "${#tbs_name[@]}" -eq "0" ]; then
    echo -e "\nSUCCESS: Nenhum tablespace encontrado para crescimento\n"
    exit 0
  else
  echo -e "\nSQL para crescer tablespaces com threshold de uso em ${tbslimit}%:\n"
    #Inicia operação de resize ou add de datafiles para tablespaces encontrados
    for tbs in $(seq 1 ${#tbs_name[@]})
    do
      #echo -e "\ntbs_name="${tbs_name[$tbs]}" tbs_size="${tbs_size[$tbs]}" space_to_add="${space_to_add[$tbs]}" dtfs_to_add="${dtfs_to_add[$tbs]}" space_to_resize="${space_to_resize[$tbs]}" dtfs_to_resize="${dtfs_to_resize[$tbs]}" total_space="${total_space[$tbs]}
      
      if [ "${space_to_resize[$tbs]}" -gt "0" ]; then #eh pq tem datafile para resize
  #Busca informações dos datafiles disponiveis    
sqlplus -s / as sysdba <<EOF > .cfgtbs_resize_${tbs_name[tbs]}
set head off
set feedback off
set lines 200
select file_name||'|'||to_char((bytes)/1024/1024)
from dba_data_files 
where bytes<34358689792
and tablespace_name='${tbs_name[tbs]}';
EOF
       for row in $(cat .cfgtbs_resize_${tbs_name[tbs]}) ##faz loop nos datafiles disponiveis
       do
         #let j++ 
         j=$((j+1))
         file_name[${j}]=$(echo $row|cut -d'|' -f1 |tr -d '\n')   #nome do datafile
         file_size[${j}]=$(echo $row|cut -d'|' -f2 |tr -d '\n')   #tamanho do datafile
         
         resize_diff=$(awk -v file_size="${file_size[${j}]}" 'BEGIN{ printf("%.f\n", (32767-file_size) ) }')
         size_value=$(awk -v total_space="${total_space[${tbs}]}" -v file_size="${file_size[${j}]}"  'BEGIN{ printf("%.f\n", (total_space+file_size) ) }')               #tamanho do datafile 
         total_space[${tbs}]=$(awk -v total_space="${total_space[${tbs}]}" -v resize_diff="${resize_diff}" 'BEGIN{ printf("%.f\n", (total_space-resize_diff) ) }')
         
         #echo -e "\n  res>> file_name="${file_name[${j}]}" file_size="${file_size[${j}]}" resize_diff="${resize_diff}" total_space="${total_space[${tbs}]}
  
         if ( [ "${total_space[${tbs}]}" -gt "0" ]  && [ "${total_space[${tbs}]}" -ge "${space_to_add[${tbs}]}" ] ); then
           
           if [ "${size_value}" -gt "32767" ]; then
             size_value="32767"           
           fi
           echo "alter database datafile '"${file_name[${j}]}"' resize "${size_value}"M;"
          
         else  ##faz o resize para um datafile
           echo "alter database datafile '"${file_name[${j}]}"' resize "${size_value}"M;"
           break;
         fi
  
       done
  
      fi
        for dtfs in $(seq 1 ${dtfs_to_add[$tbs]})
        do
          #echo "dtfs="${dtfs}
          #echo "dtfs_to_add="${dtfs_to_add[$tbs]}
          if [ "${space_to_add[$tbs]}" -lt "${dtfsize}" ]; then
            size_tbs=${space_to_add[$tbs]}
          else
            space_to_add[$tbs]=$(awk -v space_to_add="${space_to_add[$tbs]}" -v dtfsize="${dtfsize}" 'BEGIN{print (space_to_add-dtfsize)}')
            size_tbs=${space_to_add[$tbs]}
          fi
          
          if [ "${dtfs}" -eq "${dtfs_to_add[$tbs]}" ]; then ##eh o ultimo elemento do array ou tem somente um elemento
            echo -e "alter tablespace "${tbs_name[tbs]}" add datafile '+"${dg_name}"' size "${size_tbs}"M;"
          else 
            echo -e "alter tablespace "${tbs_name[$tbs]}" add datafile '+"${dg_name}"' size "$dtfsize"M;"
          fi
        done      
  
  
      
  
    done
    
    echo
    fi;
  

fi

##EXECUTA PARA CADA PMON ENCONTRADO
#for i in $(ps -ef | grep pmon | egrep -v "ASM|grep|APX|MGMTDB" | awk {' print substr($8,10) '}); do

#do
