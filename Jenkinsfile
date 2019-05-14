pipeline {
    environment {
        ROOM_NAME = 'cicd_test'
        buildTag = "UNKNOWN"
        ARTIFACTID = "UNKNOWN"
        customImage = "UNKNOWN"
        SLACK_TOKEN = "8tkgD5y7650nerdCf2WV7Af0"
    }

    options {
       disableConcurrentBuilds()
       buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    agent {
        kubernetes {
          label 'github-test'
          defaultContainer 'jnlp'
          yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    project: github-test
spec:
  containers:
  - name: jnlp
    image: jenkins/jnlp-slave:3.27-1-alpine
  - name: dind
    image: docker:stable-dind
    command:
      - dockerd
    args:
      - --host=unix:///var/run/docker.sock
      - --host=tcp://0.0.0.0:2375
      - --storage-driver=vfs
    securityContext:
      privileged: true
  - name: ansible
    image: williamyeh/ansible:alpine3
    command:
      - sleep
    args:
      - 10000
  restartPolicy: Always
"""
        }
    }

    stages {
        stage('Notify: started') {
            steps {
                slackSend (color: '#FFFF00', token: "${SLACK_TOKEN}",
                    message: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
                )
            }
        }

        stage('Regex') {
            steps {
                script {
                    @NonCPS
                    def gitCount = sh(script: 'git rev-list --count HEAD', returnStdout: true).trim()
                    def gitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    buildTag = sh(script: "echo ${BRANCH_NAME}.${gitCount}.${gitHash}", returnStdout: true).trim()
                    def m = env.JOB_NAME =~ "(.*)/(.*)/(.*)"
                    ARTIFACTID = m[0][2]
		    echo "a=${ARTIFACTID}"
		    echo "b=${buildTag}"
		    echo "m=${m}"
                }
            }
        }

//        stage('Package') {
//            steps {
//                script {
//                    container('dind') {
//                        if(env.BRANCH_NAME == "master") {
//                            customImage = docker.build("zhanghuiin/evatarco/${ARTIFACTID}:${buildTag}", "--build-arg DEPLOY_ENV=prod --pull .")
//                        } else if(env.BRANCH_NAME == "develop") {
//                            customImage = docker.build("zhanghuiin/evatarco/${ARTIFACTID}:${buildTag}", "--build-arg DEPLOY_ENV=sit --pull .")
//                        }
//                    }
//                }
//            }
//        }
//
//        stage('Publish') {
//            steps {
//                script {
//                    if(env.BRANCH_NAME =~ /^(master|develop)$/) {
//                        container('dind') {
//                            withDockerRegistry([ credentialsId: "evatar_5252play_pb_hub", url: "https://registry.5252play.com" ]) {
//                                customImage.push()
//                                customImage.push("latest")
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//        stage('Deploy') {
//            steps {
//                script {
//                    container('ansible') {
//                        if(env.BRANCH_NAME == "develop") {
//                            dir('deployer') {
//                                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'JenkinsDev', url: 'git@bitbucket.org:evatar/being-deployer.git']]])
//                                dir('ansible-document-signing-test-deployer/') {
//                                    sshagent(credentials: ['BeingSigningTestDeployer']) {
//                                        sh """ansible-playbook -b deployer.yml -e 'artifactId=${ARTIFACTID} build=${buildTag}'"""
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
    post {
        success {
            slackSend (color: '#00FF00', token: "${SLACK_TOKEN}",
                message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
            )
        }
        failure {
            slackSend (color: '#FF0000', token: "${SLACK_TOKEN}",
                message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
            )
        }
    }
}
