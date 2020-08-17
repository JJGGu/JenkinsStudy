pipeline {
   agent any
   environment {
        RUN_ENV="dev"
        DATABASEURL="jdbc:mysql://10.107.1.27:3308/cosine_test_db?allowMultiQueries=true&useUnicode=true&characterEncoding=UTF-8&useSSL=false"
        WORKFLOW="http://10.53.4.64:5999"
        MAILGATEWAY="http://openapi-private.sensetime.com/mail/v1/email/short?userId="
        MAILSERVICE="http://openapi-private.sensetime.com/auth/v1/use"
        JIRAURL="https://jira-ssl-test.sensetime.com"
        APPROVEURL="https://cosine.sensetime.com/#/workflow"
        USERINFOSERVICEURL="https://openapi-private.sensetime.com/v1/oa/userinfo"

        CUR_BRANCH="${gitlabBranch}"
        EMAIL_TO="xuhaoran@sensetime.com, wuzai@sensetime.com"
   }
   stages {
      stage('pull') {
         when{
           anyOf {
             environment name: 'CUR_BRANCH', value: 'dev';
             environment name: 'CUR_BRANCH', value: 'master'
           }
         }
         steps {
            checkout([$class: 'GitSCM', branches: [[name: "*/${CUR_BRANCH}"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '7dc9062c-d137-48aa-94ff-ec7f7311c832', url: 'http://gitlab.bj.sensetime.com/cosine/website/cosine-backend.git']]])

            script {
                env.imageTag = sh (script: 'git rev-parse --short origin/${CUR_BRANCH}', returnStdout: true).trim()
                println imageTag
            }
         }
      }
      stage('build') {
          when{
            anyOf {
              environment name: 'CUR_BRANCH', value: 'dev';
              environment name: 'CUR_BRANCH', value: 'master'
            }
          }
          steps {
              sh 'mvn clean package'
          }
      }
      stage('deploy') {
          when{
             anyOf {
               environment name: 'CUR_BRANCH', value: 'dev';
               environment name: 'CUR_BRANCH', value: 'master'
             }
          }
          steps {
              echo '开始部署'
              sh 'docker build --rm -t registry.sensetime.com/demos/cosine-backend:${imageTag} -f Dockerfile .'
              sh 'docker push registry.sensetime.com/demos/cosine-backend:${imageTag}'

          }
      }
      stage('run') {
          when{
            environment name: 'CUR_BRANCH', value: 'dev'
          }
          steps {
              echo '开始拉取并运行'
              sh 'sudo bash deploy.sh'
              sh 'sudo docker pull registry.sensetime.com/demos/cosine-backend:${imageTag}'
              sh 'sudo docker run -d  -p 10010:7999  --name cosine-backend --entrypoint ./entrypoint.sh -e RUN_ENV=$RUN_ENV -e DATABASEURL=$DATABASEURL -e WORKFLOW=$WORKFLOW -e MAILGATEWAY=$MAILGATEWAY -e MAILSERVICE=$MAILSERVICE -e JIRAURL=$JIRAURL -e APPROVEURL=$APPROVEURL -e USERINFOSERVICEURL=$USERINFOSERVICEURL --restart=always registry.sensetime.com/demos/cosine-backend:${imageTag}'
          }
      }
   }
   post {
       always {
           script{

              echo "----------------CUR_BRANCH----------------------"
              echo "${CUR_BRANCH}"
              echo "----------------CUR_BRANCH----------------------"
              env.imageTag = sh (script: 'git rev-parse --short origin/${CUR_BRANCH}', returnStdout: true).trim()
              println "-----------------IMAGETAG---------------"
              println imageTag
              println "-----------------IMAGETAG---------------"
              if("${CUR_BRANCH}" == "dev" || "${CUR_BRANCH}" == "master"){
                 emailext(
                          subject: '构建通知:${PROJECT_NAME} - Build # ${BUILD_NUMBER} -${BUILD_STATUS}!',
                          body: '${FILE,path="email.html"}',
                          to: "${EMAIL_TO}"
                 )
              } else {
                 emailext(
                          subject: '构建通知:${PROJECT_NAME} - Build # ${BUILD_NUMBER} -${BUILD_STATUS}!',
                          body: '${FILE,path="email.html"}',
                          to: "xuhaoran@sensetime.com"
                 )
              }

           }

        }
     }
}