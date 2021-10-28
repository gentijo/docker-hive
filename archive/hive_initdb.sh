#!/bin/sh

if [ ! -f "/opt/hive/bin/hive_initidb.done" ]; then
  touch /opt/hive/bin/hive_initidb.done
 /opt/hive/bin/schematool -dbType postgres -initSchema
fi

/opt/hive/bin/schematool -dbType postgres -info
