#!/bin/bash

hadoop fs -mkdir       /tmp
hadoop fs -mkdir -p    /user/hive/warehouse
hadoop fs -chmod g+w   /tmp
hadoop fs -chmod g+w   /user/hive/warehouse

cd $HIVE_HOME/bin
./hive \
 --hiveconf hive.server2.enable.doAs=false \
 --hiveconf test.tmp.dir=/tmp \
 --hiveconf test.warehouse.dir=/user/hive/warehouse \
 --hiveconf hive.root=/user/hive \
 --service  metastore
