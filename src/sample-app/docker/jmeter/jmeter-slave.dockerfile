ARG TAG
FROM 730319765130.dkr.ecr.eu-west-2.amazonaws.com/texas/jmeter-base:$TAG
		
EXPOSE 1099 50000
		
ENTRYPOINT $JMETER_HOME/bin/jmeter-server \
-Dserver.rmi.localport=50000 \
-Dserver_port=1099 \
-Jserver.rmi.ssl.disable=true
