FROM openjdk:8-jdk-slim

ARG JMETER_VERSION

RUN apt-get clean && \
apt-get update && \
apt-get -qy install \
wget \
telnet \
iputils-ping \
unzip

RUN mkdir /jmeter \
&& cd /jmeter/ \
&& wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VERSION.tgz \
&& tar -xzf apache-jmeter-$JMETER_VERSION.tgz \
&& rm apache-jmeter-$JMETER_VERSION.tgz

RUN cd /jmeter/apache-jmeter-$JMETER_VERSION/ && wget -q -O /tmp/JMeterPlugins-Standard-1.4.0.zip https://jmeter-plugins.org/downloads/file/JMeterPlugins-Standard-1.4.0.zip && unzip -n /tmp/JMeterPlugins-Standard-1.4.0.zip && rm /tmp/JMeterPlugins-Standard-1.4.0.zip

RUN wget -q -O /jmeter/apache-jmeter-$JMETER_VERSION/lib/ext/pepper-box-1.0.jar https://github.com/raladev/load/blob/master/JARs/pepper-box-1.0.jar?raw=true

RUN cd /jmeter/apache-jmeter-$JMETER_VERSION/ && wget -q -O /tmp/bzm-parallel-0.7.zip https://jmeter-plugins.org/files/packages/bzm-parallel-0.7.zip && unzip -n /tmp/bzm-parallel-0.7.zip && rm /tmp/bzm-parallel-0.7.zip

RUN cd /tmp && wget -q -O apache-log4j-2.16.0-bin.tar.gz https://dlcdn.apache.org/logging/log4j/2.16.0/apache-log4j-2.16.0-bin.tar.gz \
&& tar xzvf apache-log4j-2.16.0-bin.tar.gz \
&& cd /jmeter/apache-jmeter-$JMETER_VERSION/lib \
&& rm log4j-* \
&& cp /tmp/apache-log4j-2.16.0-bin/log4j-1.2-api-2.16.0.jar . \
&& cp /tmp/apache-log4j-2.16.0-bin/log4j-api-2.16.0.jar . \
&& cp /tmp/apache-log4j-2.16.0-bin/log4j-core-2.16.0.jar . \
&& cp /tmp/apache-log4j-2.16.0-bin/log4j-slf4j-impl-2.16.0.jar . \
&& rm -rf /tmp/apache-log4j-2.16.0-bin

ENV JMETER_HOME /jmeter/apache-jmeter-$JMETER_VERSION/
		
ENV PATH $JMETER_HOME/bin:$PATH
