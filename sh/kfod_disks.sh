for disk in $(cat /home/oracle/disks.log)
do
disco=$(echo $disk|cut -d'/' -f3)
 #-echo $(/opt/oracle/product/11.2.0.4/db/bin/kfod verbose=true disks=all status=true op=disks asm_diskstring=$disk|grep 1:)
 echo -e $(ls -l /dev/disk/by-id |grep -w $disco |grep wwn |grep -v "part" |awk {' print "brtlvlts0091fu;"$11";"$9'})
done;


for disk in $(cat /home/oracle/infodisk.log)
do
host_origem=$(echo $disk|cut -d';' -f1)
path_origem=$(echo $disk|cut -d';' -f2 |cut -d'/' -f3)
wwn_origem=$(echo $disk|cut -d';' -f3)
echo $host_origem
echo $path_origem
echo $wwn_origem
#-echo $(/opt/oracle/product/11.2.0.4/db/bin/kfod verbose=true disks=all status=true op=disks asm_diskstring=$disk|grep 1:)
path_destino=$(ls -l /dev/disk/by-id |grep -w $wwn_origem |grep wwn |grep -v "part" awk {' print "brtlvlts0092fu;"$11";"$9'})
done;

