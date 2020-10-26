#!/bin/bash
#set -x

if [ `ps -ef |grep telegraf |grep config |wc -l` -eq 0 ]
then
   /dbs/tools/telegraf/usr/bin/telegraf --config /dbs/tools/telegraf/etc/telegraf/telegraf.conf &
fi
#set +x
exit