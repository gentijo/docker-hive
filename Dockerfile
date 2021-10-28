FROM gentijo/hadoop:v0.1

# Allow buildtime config of HIVE_VERSION
# Set HIVE_VERSION from arg if provided at build, env if provided at run, or default
# https://docs.docker.com/engine/reference/builder/#using-arg-variables
# https://docs.docker.com/engine/reference/builder/#environment-replacement

ARG HIVE_VERSION
Env HIVE_VERSION=${HIVE_VERSION:-3.1.2}

ENV HIVE_HOME /opt/hive
ENV PATH $HIVE_HOME/bin:$PATH

RUN mkdir -p /opt/hive_temp
ENV TEST_TEMP_DIR=/opt/hive_temp

RUN mkdir -p /opt/hive_warehouse
ENV TEST_WAREHOUSE_DIR=/opt/hive_warehouse

RUN mkdir -p /opt/hive_root
ENV HIVE_ROOT=/opt/hive_root

ENV HIVE_DB_CONNECTION_URL=jdbc:postgresql://postgres/metastore
ENV HIVE_DB_DRIVER=org.postgresql.Driver
ENV HIVE_DB_USER=postgres
ENV HIVE_DB_PASS=pgpass

ENV ZOOKEEPER_VERSION=3.7.0
ENV ZOOKEEPER_HOME=/opt/zookeeper

RUN apt update; exit 0
RUN apt upgrade -y; exit 0
RUN apt install -y wget nano procps passwd adduser gettext-base zookeeper


RUN addgroup hive
RUN addgroup hadoop
RUN adduser --ingroup hive hive
RUN usermod -a -G hadoop hive

WORKDIR /opt
COPY bin/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz /opt
RUN tar -xzvf apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz
RUN mv apache-zookeeper-${ZOOKEEPER_VERSION}-bin zookeeper
RUN rm apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz
RUN mkdir -p /tmp/zookeeper
ADD conf/zoo.cfg $ZOOKEEPER_HOME/conf

WORKDIR /opt
#RUN wget https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz

COPY bin/apache-hive-${HIVE_VERSION}-bin.tar.gz /opt
RUN tar -xzvf apache-hive-$HIVE_VERSION-bin.tar.gz
RUN mv apache-hive-$HIVE_VERSION-bin hive
RUN chmod -R 755 /opt/hive
RUN chown -R hive:hive /opt/hive

# Get rid of the old troublesome one first.
RUN rm $HIVE_HOME/lib/postgresql-9.4.1208.jre7.jar

#install Postgress lib
RUN wget https://jdbc.postgresql.org/download/postgresql-42.2.24.jar -O $HIVE_HOME/lib/postgresql-jdbc.jar

#Custom configuration goes here

COPY conf/hive-site.xml $HIVE_HOME/conf/hive-site.orig
RUN envsubst < $HIVE_HOME/conf/hive-site.orig > $HIVE_HOME/conf/hive-site.xml

ADD conf/beeline-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-env.sh $HIVE_HOME/conf
ADD conf/hive-exec-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-log4j2.properties $HIVE_HOME/conf
ADD conf/ivysettings.xml $HIVE_HOME/conf
ADD conf/llap-daemon-log4j2.properties $HIVE_HOME/conf

COPY hive_entrypoint.sh ${HIVE_HOME}/bin/hive_entrypoint.sh
RUN chmod +x ${HIVE_HOME}/bin/hive_entrypoint.sh

EXPOSE 10000
EXPOSE 10002

ENTRYPOINT ["/opt/hive/bin/hive_entrypoint.sh"]
