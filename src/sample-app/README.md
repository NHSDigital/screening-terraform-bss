# Sample Deployment Pipeline

##
This deployment pipeline contains a very simple java endpoint application which returns 'Hello World'

##
Note that it uses a multi-stage docker build which means that the resulting image is smaller and therefore quicker to push/pull and deploy because it doesn't contain unnecessary build packages

##
This repo also includes a fully-working jMeter stack, sample JMX file and pipeline stages to manage it

## 
Future enhancements to this repo could include:

* Terraform example (e.g. ECR)
* A better way of managing k8s config than sed (kustomize? Terraform k8s provider?)
* Slack build notification example
* Sample pipelines for other common NHSD programming languages e.g. .net, Javascript?, python?
* Sonarqube integration
* Nexus integration
* GitHub integration
* AWS FIS example
