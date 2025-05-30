#!/usr/bin/env bash

set -e

testdir="$1"
echo ""

if [ ! -d "$testdir" ];
then
  echo "Test files dir was not found in PATH"
  echo "Kindly check and input the correct path"
  exit 1
else 
  echo "testdir set to $testdir"
fi
testdir_basename="$(basename "$testdir")"
echo "testdir_basename set to $testdir_basename"
echo ""

jmxfile="$2"
if [ ! -f "$jmxfile" ];
then
  echo "JMX file not found in PATH"
  echo "Kindly check and input the correct filename"
  exit 1
else 
  echo "jmxfile set to $jmxfile"
fi
jmxfile_basename="$(basename "$jmxfile")"
echo "jmxfile_basename set to $jmxfile_basename"
echo ""

if [ $3 ]
then
  echo "Setting jmeter properties file to $3"
  jmproperties="$3"
  jmproperties_basename="$(basename "$jmproperties")"
  if [ ! -f "$jmproperties" ];
  then
    echo "jMeter properties file $3 was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit 1
  fi
else
  echo "No custom properties file specifed"
fi

#Get Master pod details
master_pod=`kubectl get po | grep jmeter-master | awk '{print $1}'`
echo "master_pod set to $master_pod"
echo ""

## Copying test files onto pod
kubectl cp "$testdir" "$master_pod:/$testdir_basename"
echo "Copied performance test files to pod"

# Assumes input data for test will be in Excel format as opposed to CSV
if [ -f $testdir/*.xlsx ]
then
  echo "Found Excel file in $testdir, copying file to slave"
  #Get slave pod details - assumes one slave for now
  slave_pod=`kubectl get po | grep jmeter-slave | awk '{print $1}'`
  echo "slave_pod set to $slave_pod"
  echo ""
  kubectl cp $testdir/*.xlsx "$slave_pod:/"
else
  echo "Excel test data file(s) not found"
fi

# This has only been tested for user.properties which is already enabled in jmeter.properties, other .properties files may require changes to the jmeter-master image/deployment
if [ $jmproperties ]
then 
  kubectl cp "$jmproperties" "$master_pod:/jmeter/apache-jmeter-5.4.1/bin/$jmproperties_basename"
else
  echo "custom properties not set"
fi 

## Removing previous report .csv
kubectl exec -i $master_pod -- rm -rf jm_report
echo "removed previous csv report file"

## Copy latest JMX file to the master pod
kubectl cp "$jmxfile" "$master_pod:/${testdir_basename}/${jmxfile_basename}"
## Copy load test script to master pod
kubectl cp "jmeter/scripts/load_test.sh" "$master_pod:/load_test.sh"

## Echo Starting Jmeter load test
kubectl exec -i $master_pod -- /bin/bash /load_test.sh "/${testdir_basename}/${jmxfile_basename}"
echo "ran JMeter tests"

## Removing previous html report dir
kubectl exec -i $master_pod -- rm -rf jm_report
echo "removed previous report HTML file"

## Generating HTML report
kubectl exec -i $master_pod -- jmeter -g jm_report.csv -o jm_report
echo "generated new HTML report file"

## Copying HTML report from pod to Jenkins workspace
kubectl cp "$master_pod:/jm_report" ./test-results/jm_report
echo "copied HTML report files to workspace"

## Copying .csv report from pod to Jenkins workspace
kubectl cp "$master_pod:/jm_report.csv" ./test-results/jm_report/jm_report.csv
echo "Copied CSV report file to workspace"
