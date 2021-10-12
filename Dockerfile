FROM gentijo/hadoop


# Allow buildtime config of HIVE_VERSION
# Set HIVE_VERSION from arg if provided at build, env if provided at run, or default
# https://docs.docker.com/engine/reference/builder/#using-arg-variables
# https://docs.docker.com/engine/reference/builder/#environment-replacement

ARG HIVE_VERSION
Env HIVE_VERSION=${HIVE_VERSION:-3.1.2}

ENV HIVE_HOME /opt/hive
ENV PATH $HIVE_HOME/bin:$PATH

RUN mkdir -p /opt/hive_temp
ENV test.tmp.dir=/opt/hive_temp

RUN mkdir -p /opt/hive_warehouse
ENV test.warehouse.dir=/opt/hive_warehouse

RUN mkdir -p /opt/hive_root
ENV hive.root=/opt/hive_root

RUN apt update; exit 0
RUN apt upgrade -y; exit 0
RUN apt install -y wget nano procps passwd adduser postgresql derby-tools

RUN addgroup hive
RUN addgroup hadoop
RUN adduser --ingroup hive hive
RUN usermod -a -G hadoop hive

WORKDIR /opt
#RUN wget https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz

COPY bin/apache-hive-${HIVE_VERSION}-bin.tar.gz /opt
RUN tar -xzvf apache-hive-$HIVE_VERSION-bin.tar.gz
RUN mv apache-hive-$HIVE_VERSION-bin hive
RUN chmod -R 755 /opt/hive
RUN chown -R hive:hive /opt/hive

#install Postgress lib
#RUN wget https://jdbc.postgresql.org/download/postgresql-42.2.24.jar -O $HIVE_HOME/lib/postgresql-jdbc.jar


#Custom configuration goes here
ADD conf/hive-site.xml $HIVE_HOME/conf
ADD conf/beeline-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-env.sh $HIVE_HOME/conf
ADD conf/hive-exec-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-log4j2.properties $HIVE_HOME/conf
ADD conf/ivysettings.xml $HIVE_HOME/conf
ADD conf/llap-daemon-log4j2.properties $HIVE_HOME/conf

COPY startup.sh /usr/local/bin/hive_startup.sh
RUN chmod +x /usr/local/bin/hive_startup.sh

COPY hive_entrypoint.sh /usr/local/bin/hive_entrypoint.sh
RUN chmod +x /usr/local/bin/hive_entrypoint.sh

EXPOSE 10000
EXPOSE 10002

#ENTRYPOINT ["/usr/local/bin/hive_entrypoint.sh"]
ENTRYPOINT [ "/bin/bash" ]
