#!/usr/bin/env bash
# Script written to stop a running jmeter master test
# Assumes you are authenticated with k8s and context (namespace) is already set

master_pod=`kubectl get po | grep jmeter-master | awk '{print $1}'`

kubectl exec -ti $master_pod -- bash /jmeter/apache-jmeter-5.4.1/bin/stoptest.sh
