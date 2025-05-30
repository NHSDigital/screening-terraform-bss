Adapted from the Kubernauts article/repos referenced here:
https://goo.gl/mkoX9E

Start with the example Jenkinsfile in /jenkins.

Update the variables to match:
* your service team (e.g. dspt)
* application name (e.g. dspt)
* environment (e.g. dev/uat)

Texas environment should usually stay as live-lk8s-nonprod

EITHER start with the example JMX file in /jmeter/tests/loadtest1/ and change:
* the URL (this is managed by the pipeline currently)
* no. of threads (concurrent users)
* test duration

OR (better) install jMeter5.4.x on your workstation (Windows/Mac) and use the UI
to generate your JMX file(s).

You can adapt the load_test.sh script as required if you need jMeter to be
called wih different flags. It will get copied onto the master/slave pods by
start_test.sh.

start_test.sh is (currently) invoked with 3 arguments, the last one being 
optional:

e.g. ./start_test.sh ../tests/loadtest1 ../tests/loadtest1/example.jmx ../properties/user.properties

start_test can be run locally or from jenkins

The sample Jenkins pipeline file includes a stage to deploy to jMeter using the yaml files in k8s and will deploy to the namespace <serviceTeamShortname>-<serviceTeamEnvName>-jmeter e.g. dspt-dev-jmeter.

start_test.sh includes the generation of an HTML report and the pipeline example saves these build artifacts so they are visible in the Jenkins UI. In order for these to be displayed correctly, as an administrator, follow the instructions below:

* Manage Jenkins->
* Manage Nodes->
* Click settings(gear icon)->
* click Script console on left and type in the following command:

  ```
  System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", "")
  ```
