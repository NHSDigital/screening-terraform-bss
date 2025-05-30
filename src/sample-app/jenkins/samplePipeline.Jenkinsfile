properties([
  buildDiscarder(
    logRotator(numToKeepStr: '15')
  ),
  disableConcurrentBuilds(),
  gitLabConnection('Jenkins-Gitlab'),
  parameters([
    booleanParam( name: 'JMETER', defaultValue: false, description: "If all pipeline, run jmeter." )
  ])
])

// AWS vars
def awsDefaultRegion = 'eu-west-2'
def awsRegion
def ecrAccountName = 'live-mgmt'
def ecrAccountId = '461183108257'

// Regions
def regionAbbrMap = ["eu-west-1":"euw1", "eu-west-2":"euw2", "eu-west-3":"euw3", "eu-central-1":"euc1", "eu-central-2":"euc2", "eu-south-1":"eus1", "eu-south-2":"eus2",
                    "eu-north-1":"eun1", "us-east-1":"use1", "us-east-2":"use2", "us-west-1":"usw1", "us-west-2":"usw2", "af-south-1":"afs1", "ca-central-1":"cac1",
                    "il-central-1":"ilc1", "me-south-1":"mes1", "me-central-1":"mec1", "sa-east-1":"sae1", "ap-east-1":"ape1", "ap-south-1":"aps1", "ap-south-2":"aps2",
                    "ap-southeast-1":"apse1", "ap-southeast-2":"apse2", "ap-southeast-3":"apse3", "ap-southeast-4":"apse4", "ap-northeast-1":"apne1", "ap-northeast-2":"apne2",
                    "ap-northeast-3":"apne3"]

// Jenkins variables
def jobName = "${env.JOB_NAME}"
def branchName = "${env.BRANCH_NAME}"
// simplifiedBranchName is used for namespaces, so removing feature prefix, converting to lower case and truncating...
simplifiedBranchName = branchName.replace("feature/", "").toLowerCase()
if ( simplifiedBranchName.length() > 24 ){
  echo "truncating branch name for use in namespaces ..."
  simplifiedBranchName = simplifiedBranchName.substring(0,23)
}
def jenkinsUrl = "${env.BUILD_URL}"
def jenkinsScriptsDir = 'jenkins/scripts'
def jobFolder = "sample-pipelines"

// App & service Team vars
def appName = "sample-app"
def appDockerDir = 'docker/sample-java-app'
def dockerImage = 'sample-app'
def serviceTeam = "texas"
def serviceTeamEnvName = 'dev'
def imageTag
def pullThroughCacheRepo = 'texas-pull-through-dkr'

// k8s vars
def jMeterK8sDir = 'k8s/jmeter'
def appK8sDir = 'k8s/sample-java-app/helm'
def appNamespace = "${serviceTeam}-${simplifiedBranchName}-${serviceTeamEnvName}"

//*******TAGS******************
//***** BILLING TAGS ******
def serviceTag = "texas"
def serviceOwnerTag = "joel1"
def versionTag = "1.0"
def projectNameTag = "Sample Java App with helm"
//******* Environment Tags *******
def dataClassificationTag = "1"
def environmentTag = serviceTeamEnvName
def publicFacingTag = "N"
//****** Application information Tags *******
def appNameTag = "nhse-texas-sample-java-app"
def rvTag = "1"
def buildDateTag = new Date().format("dd-MM-yyyy")
def buildTimeTag = new Date().format("HH:mm")
def stackTag = "demo"
def toolTag = "k8s"
//******************************

def texasEnvName
def envDomain
def clusterName

try {
    jmeterEnabled = params.JMETER.toBoolean()
} catch (e) {
    jmeterEnabled = false
}
finally {
    echo "jmeter running? ${jmeterEnabled}"
}
def jmeterDir = 'jmeter'
def jmeterScriptsDir = "${jmeterDir}/scripts"
def jmeterTestDir = "${jmeterDir}/tests/loadtest1"
def jmxFile = "example.jmx"
def jmeterNamespace = "${serviceTeam}-${serviceTeamEnvName}-${simplifiedBranchName}-jmeter"

// ************************************************************************************
// Jenkins job folder/names must match the following convention EXACTLY:
//
// sample-pipeline/<service team name>/deploy to (live-lk8s-nonprod|live-lk8s-prod)
//
//   e.g. sample-pipelines/dspt/deploy to live-lk8s-nonprod
//
// ************************************************************************************

echo "BUILD_URL is ${BUILD_URL}"

// Get service team and target environment from Jenkins job name
if ( jobName ==~ /${jobFolder}\/([a-zA-Z\-_0-9]*)\/deploy to (dev-k8s|dev-mgmt|test-k8s|test-mgmt|live-nonprod|live-lk8s-nonprod|live-mgmt|live-prod)\/.*/ ){
  def envMatch = jobName =~ /${jobFolder}\/([a-zA-Z\-_0-9]*)\/deploy to (dev-k8s|dev-mgmt|test-k8s|test-mgmt|live-nonprod|live-lk8s-nonprod|live-mgmt|live-prod)\/.*/
  serviceTeam = envMatch[0][1]
  texasEnvName = envMatch[0][2]
  awsRegion = awsDefaultRegion
}
else if ( jobName ==~ /([a-z-]{7,13}-[0-9]{1})\/${jobFolder}\/([a-zA-Z\-_0-9]*)\/deploy to (dev-k8s|test-k8s|live-nonprod)\/.*/ ) {
  def envMatch = jobName =~ /([a-z-]{7,13}-[0-9]{1})\/${jobFolder}\/([a-zA-Z\-_0-9]*)\/deploy to (dev-k8s|test-k8s|live-nonprod)\/.*/
  serviceTeam = envMatch[0][2]
  texasEnvName = envMatch[0][3]
  awsRegion = envMatch[0][1]
}
else if ( ( texasEnvName != 'live-nonprod' ) && ( serviceTeam != 'texas' ) ){
  println "Only Texas can deploy this pipeline to environments other than non-prod"
  currentBuild.result = 'FAILURE'
  return
}
else {
  println "Invalid job name"
  currentBuild.result = 'FAILURE'
  return
}

// // Set config from environment
if ( awsRegion ==~ /(us|af|ap|ca|eu|il|me|sa)-(east|west|south|north|central|southeast|northeast)-(1|2|3|4)*/) {
  awsRegionAbbr = regionAbbrMap["${awsRegion}"]
}
else {
  error ("Invalid Region: ${awsRegion}")
}

// jenkins-agent-local is the local agent running on live-mgmt
def localNodeLabel = "jenkins-agent-local"
def remoteNodeLabel = "jenkins-agent-${texasEnvName}"

// temporary workaround until all STs are using new agent label (they only use nonprod for sample pipeline)
if (texasEnvName == "live-lk8s-nonprod") {
  remoteNodeLabel = "jenkins-slave-nonprod-k8s"
}

def mapOfMaps = [
  "clusterNames": [
    "test-k8s":"test-leks-cluster",
    "test-mgmt":"test-mgmt-leks-cluster",
    "dev-k8s":"dev-leks-cluster",
    "dev-mgmt":"dev-mgmt-leks-cluster",
    "live-mgmt":"live-mgmt-leks-cluster",
    "live-nonprod":"live-leks-cluster",
    "live-lk8s-nonprod":"live-leks-cluster",            // temporary until all STs using renamed agent label
    "live-prod":"live-leks-cluster"
  ],
  "envDomain": [
    "test-k8s":"k8s.texastest.uk",
    "test-mgmt":"mgmt.texastest.uk",
    "dev-k8s":"k8s.texasdev.uk",
    "dev-mgmt":"mgmt.texasdev.uk",
    "live-mgmt":"mgmt.texasplatform.uk",
    "live-nonprod":"k8s-nonprod.texasplatform.uk",
    "live-lk8s-nonprod":"k8s-nonprod.texasplatform.uk",   // temporary until all STs using renamed agent label
    "live-prod":"k8s-prod.texasplatform.uk"
  ]
]

clusterName = mapOfMaps["clusterNames"][texasEnvName]
envDomain = mapOfMaps["envDomain"][texasEnvName]

// Jenkins lockable resource name
def lockName = "${serviceTeam}-${texasEnvName}-${simplifiedBranchName}"

// The following variables are used for health checks after the deployment
// Note the trailing '.' !
hostedZoneName = "${envDomain}."
fqdn = "${appNamespace}-${appName}.${envDomain}"
r53Record = "${fqdn}."
path = '/MHSEndpoint'
url = "https://${fqdn}${path}"
searchText = 'Hello World'
podName = 'sample-app'
ingressName = 'sample-app'
albScheme = 'internal' // 'internal' or 'internet-facing'

def postFailure() {
    updateGitlabCommitStatus name: 'build', state: 'failed'
}

def postSuccess() {
    updateGitlabCommitStatus name: 'build', state: 'success'
}

def getDockerBuildArgs(List<String> argsList) {
  return argsList.collect { "--build-arg $it" }.join(" ")
}

/*
The intention is that we use a tagging method to identify versions that have previously been built.
How we do this will be on a case-by-case basis - for this repo which is rarely updated, and dockerfiles
are static with hardcoded base image versions, using the git commit hash will suffice.
*/
def hasImageBeenBuilt(repoName, awsRegion, imageTag) {
  def output = sh(script: """
      aws ecr describe-images --repository-name ${repoName} --region ${awsRegion} --query 'imageDetails[?imageTags != null && contains(imageTags, `${imageTag}`)]'
  """, returnStdout: true).trim()
  def jsonOutput = readJSON(text: output)
  return jsonOutput.size() > 0
}

try {

  node(localNodeLabel) {
    stage('Print Config'){
      echo "################ JOB CONFIG ########################"
      echo "  localNodeLabel is: ${localNodeLabel}"
      echo "  remoteNodeLabel is: ${remoteNodeLabel}"
      echo "  serviceTeam is: ${serviceTeam}"
      echo "  serviceTeamEnvName is: ${serviceTeamEnvName}"
      echo "  texasEnvName is: ${texasEnvName}"
      echo "  awsRegion is: ${awsRegion}"
      echo "  awsRegionAbbr is: ${awsRegionAbbr}"
      echo "  hostedZoneName is: ${hostedZoneName}"
      echo "  FQDN is: ${fqdn}"
      echo "  Test URL is: ${url}"
      echo "  branchName is: ${branchName}"
      echo "  appName is: ${appName}"
      echo "  appNamespace is: ${appNamespace}"
      echo "  lockName is: ${lockName}"
      echo "  jenkinsScriptsDir is: ${jenkinsScriptsDir}"
      echo "  jmeterScriptsDir is: ${jmeterScriptsDir}"
      echo "  jmeterTestDir is: ${jmeterTestDir}"
      echo "  jmxFile is: ${jmxFile}"
      echo "####################################################"
    }

    stage('Checkout') {
      echo 'Git repository checkout...'
      checkout scm
    }

    stage('Wait for Docker Daemon'){
      echo "Checking docker availability..."
      sh "timeout 60 bash -c 'while ! docker info &>/dev/null; do sleep 1; done' || exit 1"
      echo "The Daemon is here"
    }

    stage('Build & Push') {
      // use the commit hash as the image tag
      imageTag = sh(script: "git rev-parse HEAD", returnStdout: true).trim()
      ecrRepo = "${ecrAccountId}.dkr.ecr.${awsRegion}.amazonaws.com/${dockerImage}"
      // Authenticate against ECR
      sh """aws ecr get-login-password --region ${awsRegion} | docker login --username AWS --password-stdin ${ecrAccountId}.dkr.ecr.${awsRegion}.amazonaws.com"""
      // Create repo if it doesn't exist
      sh """
        aws ecr describe-repositories --registry-id ${ecrAccountId} --repository-names ${dockerImage} --region ${awsRegion} \
        || aws ecr create-repository --registry-id ${ecrAccountId} --repository-name ${dockerImage} --region ${awsRegion} --tags Key=Service,Value=texas
      """
      if (!hasImageBeenBuilt(dockerImage, awsRegion, imageTag)) {
        buildArgs = getDockerBuildArgs(["AWS_REGION=${awsRegion}", "ACCOUNT_ID=${ecrAccountId}", "PULL_THROUGH_REPO=${pullThroughCacheRepo}"])
        sh """docker build ${buildArgs} -t ${dockerImage}-build:${imageTag} -f ${appDockerDir}/pipeline-build.dockerfile ."""
        runtimeBuildArgs = buildArgs + " --build-arg VERSION=${imageTag}"
        sh """docker build ${runtimeBuildArgs} -t ${ecrRepo}:${imageTag} -f ${appDockerDir}/pipeline-runtime.dockerfile ."""
        // Push image to ECR
        sh """docker push ${ecrRepo}:${imageTag}"""
      } else {
        echo "Skipping building and pushing - remote image found tagged with current commit hash..."
      }
    }
  }


  node(remoteNodeLabel) {

    stage('Checkout') {
      echo 'Git repository checkout...'
      checkout scm
    }

    stage("Authenticate to ${texasEnvName}") {

      kubeconfig = sh (script: """ aws eks update-kubeconfig --region=${awsRegion} --name=${clusterName} """, returnStdout: true).split(/\s+/).last()
      sh """aws sts get-caller-identity"""
      echo "kubeconfig is: ${kubeconfig}"
    }

    stage("Terraform (placeholder)"){
      echo "placeholder for e.g. RDS, ECR"
    }

    stage("Update DB schema (placeholder)"){
      echo "placeholder e.g. using Flyway"
    }

    stage("Add Instana release marker") {
      releaseMarker releaseName: "${serviceTeam} ${texasEnvName} release ${currentBuild.number}", applications: [application (name: "Texas Sample App")]
    }

    stage("Deploy ${appName}"){
      // Prevent concurrent deployments to same env using Jenkins lockable resource
      lock ("${lockName}"){
        withEnv(["KUBECONFIG=${kubeconfig}"]) {
          wildcardCertDomainName = "*.${envDomain}"
          certArn = sh( script: """aws acm list-certificates --region ${awsRegion} | jq -r --arg jq_domainname ${wildcardCertDomainName} '.CertificateSummaryList[] | select(.DomainName == \$jq_domainname ) | .CertificateArn' """, returnStdout: true ).trim()

          echo "Texas wildcard cert ARN is: ${certArn}"

          dir ( appK8sDir ){
            sh """helm template sample-app sample-app/ --values sample-app/values.yaml"""
            sh """helm upgrade --install --create-namespace --namespace ${appNamespace} sample-app sample-app/ --values sample-app/values.yaml \
              --set image.repository=${ecrRepo} \
              --set image.tag=${imageTag} \
              --set ingress.annotations.alb\\\\.ingress\\\\.kubernetes\\\\.io/certificate-arn='${certArn}' \
              --set ingress.annotations.alb\\\\.ingress\\\\.kubernetes\\\\.io/tags='Service=${serviceTag}\\, Owner=${serviceOwnerTag}\\, TagVersion=${versionTag}\\, Project=${projectNameTag}\\, DataClassification=${dataClassificationTag}\\, Environment=${environmentTag}\\, PublicFacing=${publicFacingTag}\\, Name=${appNameTag}\\, ReleaseVersion=${rvTag}\\, BuildDate=${buildDateTag}\\, BuildTime=${buildTimeTag}\\, Stack=${stackTag}\\, Tool=${toolTag}'
            """
          }
        }
      }
    }

    stage('Associate Pod Identity'){
    // all managements texas-jenkins-pod-addon-role
    // arn:aws:iam::782914191970:role/texas-dev-pod-addon-role
    // arn:aws:iam::950573124017:role/texas-prod-pod-addon-role
      withEnv(["KUBECONFIG=${kubeconfig}"]) {
          accountId = sh (script: """aws sts get-caller-identity | jq --raw-output '.Account' """, returnStdout: true ).trim()
          echo "accountid is ${accountId}"
          if ( texasEnvName == 'live-lk8s-nonprod' || texasEnvName == 'live-nonprod'){
            roleEnv = 'nonprod'
          } else if ( texasEnvName == 'live-lk8s-prod' || texasEnvName == 'live-prod') {
            roleEnv = 'prod'
          } else if ( texasEnvName == 'test-lk8s' || texasEnvName == 'test-k8s') {
            roleEnv = 'test'
          } else if ( texasEnvName == 'dev-lk8s' || texasEnvName == 'dev-k8s') {
            roleEnv = 'dev'
          }
          else if ( texasEnvName == 'test-mgmt' || texasEnvName == 'dev-mgmt' || texasEnvName == 'live-mgmt') {
            roleEnv = 'jenkins'
          }
          roleArn = "arn:aws:iam::${accountId}:role/${serviceTeam}-${roleEnv}-pod-addon-role"
          if (texasEnvName.contains("mgmt")){
            roleArn = "arn:aws:iam::${accountId}:role/${serviceTeam}-jenkins-pod-addon-role"
          }
          sh (script: """ aws eks create-pod-identity-association --cluster-name ${clusterName} --namespace ${appNamespace} --service-account sample-app --role-arn ${roleArn} """, returnStdout: true)
          associationId = sh (script: """ aws eks list-pod-identity-associations --cluster-name ${clusterName} --namespace ${appNamespace} | jq  -r  '.associations[] | select(.serviceAccount == "sample-app") | .associationId'""", returnStdout: true)
          sh (script: """ aws eks delete-pod-identity-association --cluster-name ${clusterName} --association-id ${associationId} """, returnStdout: true)
        }
    }

    stage ("Test the endpoint"){
      withEnv(["KUBECONFIG=${kubeconfig}"]) {
        // Wait for jenkins pod to be available - currently takes around 5 mins
        sh """${jenkinsScriptsDir}/check_pods.sh ${podName} ${appNamespace} 5 25"""

        sleep 10 // to allow time for ingress to be created after pods ready

        // // Ensure ingress is ready with updated epochtime annotation before attempting to query ALB health (otherwise may return old endpoint)
        // sh """${jenkinsScriptsDir}/check_ingress.sh ${ingressName} ${appNamespace} ${epochtime} 5 30"""

        loadBalancerDNSName = sh ( script: """kubectl get ingress ${ingressName} -n ${appNamespace} -o json | jq -r '.status.loadBalancer.ingress[].hostname' """, returnStdout: true ).trim()
        echo "loadBalancerDNSName is ${loadBalancerDNSName}"

        loadBalancerArn = sh ( script: """aws elbv2 describe-load-balancers --region=${awsRegion} | jq -r --arg jq_lbdnsname ${loadBalancerDNSName} '.LoadBalancers[] | select(.DNSName == \$jq_lbdnsname) | .LoadBalancerArn'""", returnStdout: true ).trim()
        echo "loadBalancerArn is ${loadBalancerArn}"

        targetGroupArn = sh ( script: """aws elbv2 describe-target-groups --region=${awsRegion} | jq -r --arg jq_lbarn ${loadBalancerArn} '.TargetGroups[] | select(.LoadBalancerArns == [\$jq_lbarn]) | .TargetGroupArn'""", returnStdout: true ).trim()
        echo "targetGroupArn is ${targetGroupArn}"

        sh """${jenkinsScriptsDir}/check_alb.sh ${targetGroupArn} 30 20 ${awsRegion}"""

        echo "HostedZoneName ${hostedZoneName}"
        hostedZoneId = sh( script: """ aws route53 list-hosted-zones | jq -r --arg jq_hostedzonename ${hostedZoneName} '.HostedZones[] | select(.Name == \$jq_hostedzonename) | .Id' """, returnStdout: true ).trim()
        echo "hostedZoneId is ${hostedZoneId}"

        // Note the trailing . on the target FQDN to check to for
        sh """${jenkinsScriptsDir}/check_r53.sh ${hostedZoneId} ${r53Record} ${loadBalancerDNSName}. 5 30"""

        // Only run curl against endpoint if it is publicly accessible
        if ( albScheme == 'internet-facing'){
          // Check endpoint using curl
          sh """${jenkinsScriptsDir}/curl_endpoint.sh ${url} \"${searchText}\" 5 30"""
        }
        else {
          echo '''Skipping curl check as endpoint is internal and won't be accessible'''
        }
      }
    }

    
    stage("Deploy jMeter"){
      if ( jmeterEnabled ){
        lock ("${jmeterNamespace}"){
          withEnv(["KUBECONFIG=${kubeconfig}"]) {
            jMeterNamespaceExists = sh( script: """ kubectl get ns | awk '{print \$1}' | grep '^${jmeterNamespace}\$' || true """, returnStdout: true).trim()
            if ( jMeterNamespaceExists != "${jmeterNamespace}" ) {
              echo "namespace ${jmeterNamespace} doesn't exist, creating it..."
              sh (""" kubectl create ns ${jmeterNamespace} """)
            }
            else {
              echo "namespace ${jmeterNamespace} already exists"
            }
            sh ("""sed -i 's|REPLACE_WITH_AWS_REGION|${awsRegion}|g' ${jMeterK8sDir}/jmeter_slaves_deploy.yaml """)
            sh ("""sed -i 's|REPLACE_WITH_AWS_REGION|${awsRegion}|g' ${jMeterK8sDir}/jmeter_master_deploy.yaml """)
            dir ( jMeterK8sDir ){
              sh """kubectl apply -n ${jmeterNamespace} -f jmeter_slaves_deploy.yaml"""
              sh """kubectl apply -n ${jmeterNamespace} -f jmeter_slaves_svc.yaml"""
              sh """kubectl apply -n ${jmeterNamespace} -f jmeter_master_deploy.yaml"""
            }
            // Wait for jMeter pods to be available
            sh """${jenkinsScriptsDir}/check_pods.sh jmeter-master ${jmeterNamespace} 5 30"""
            sh """${jenkinsScriptsDir}/check_pods.sh jmeter-slave ${jmeterNamespace} 5 30"""
          }
        }
      }
      else {
        echo "jmeter does not run for main pipeline"
      }
    }

    stage("Run Jmeter"){
      if ( jmeterEnabled ){
        lock ("${jmeterNamespace}"){
          withEnv(["KUBECONFIG=${kubeconfig}"]) {
            sh ("""sed -i 's|REPLACE_WITH_FQDN|${fqdn}|g' ${jmeterTestDir}/${jmxFile}""")
            sh ("""sed -i 's|REPLACE_WITH_PATH|${path}|g' ${jmeterTestDir}/${jmxFile}""")
            sh """kubectl config set-context --current --namespace=${jmeterNamespace}"""
            sh """${jmeterScriptsDir}/jmeter_stop.sh"""
            sh """${jmeterScriptsDir}/start_test.sh ${jmeterTestDir} ${jmeterTestDir}/${jmxFile}"""
          }
        }
        // Make jMeter test report files available as build artifacts
        dir('test-results') {
          archiveArtifacts artifacts: '**'
        }
      }
      else {
        echo "jmeter does not run for main pipeline"
      }
    }

      stage("Destroy jMeter") {
        if ( jmeterEnabled ){
          lock ("${jmeterNamespace}"){
            withEnv(["KUBECONFIG=${kubeconfig}"]) {
              sh """kubectl delete ns ${jmeterNamespace}"""
            }
          }
        }
        else {
          echo "jmeter does not run for main pipeline"
        }
      }

    stage("Destroy webapp") {
      // Prevent concurrent app ns destroys
      lock ("${lockName}"){
        withEnv(["KUBECONFIG=${kubeconfig}"]) {
          sh """kubectl delete ns ${appNamespace}"""
        }
      }
    }

  }

  // Post build result to GitLab
} finally {
  def currentResult = currentBuild.result ?: 'SUCCESS'
  if (currentResult == 'SUCCESS') {
    postSuccess()
  } else {
    postFailure()
  }
}
