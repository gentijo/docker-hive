#!/bin/sh
service ssh start

/opt/zookeeper/bin/zkServer.sh start

/opt/hadoop/bin/hadoop-startup.sh

if [ ! -f "/opt/hive/bin/hive_initidb.done" ]; then
  touch /opt/hive/bin/hive_initidb.done
 /opt/hive/bin/schematool -dbType postgres -initSchema
fi

/opt/hive/bin/schematool -dbType postgres -info

hadoop fs -mkdir       /tmp
hadoop fs -mkdir -p    /user/hive/warehouse
hadoop fs -chmod g+w   /tmp
hadoop fs -chmod g+w   /user/hive/warehouse

cd $HIVE_HOME/bin
/opt/hive/bin/hive \
 --hiveconf hive.server2.enable.doAs=false \
 --hiveconf test.tmp.dir=/tmp \
 --hiveconf test.warehouse.dir=/user/hive/warehouse \
 --hiveconf hive.root=/user/hive \
 --service  metastore &

/opt/hive/bin/hive \
  --hiveconf hive.server2.enable.doAs=false \
  --hiveconf test.tmp.dir=/tmp \
  --hiveconf test.warehouse.dir=/user/hive/warehouse \
  --hiveconf hive.root=/user/hive \
  --service  hiveserver2
  
