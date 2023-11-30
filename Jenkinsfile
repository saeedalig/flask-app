pipeline{
    agent any
    
    environment {
        DOCKERHUB = "asa96"
        APP_NAME = "flask-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        IMAGE_NAME = "${DOCKERHUB}" + "/" + "${APP_NAME}"
        REGISTRY_CREDS = "dockerhub"
    }


	
    stages {
	
        stage('Clean Workspace'){
            steps{
                cleanWs()
            }
        }
		
        stage('Git Checkout'){
            steps{
                git branch: 'main', url: 'https://github.com/saeedalig/flask-app.git'
            }
        }
        
        stage('Build Docker Image'){
            steps{
                script {
                    docker_image = docker.build("${IMAGE_NAME}")
                }
            }
        }
        
        // stage('Push Docker Image'){
        //     steps {
        //         script{
        //             docker.withRegistry('', REGISTRY_CREDS ){
        //                 docker_image.push("${BUILD_NUMBER}")
        //                 docker_image.push('latest')
        //             }
        //         }
        //     }
        // }
        
        // stage('Delete Docker Images'){
        //     steps {
        //         sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG}"
        //         sh "docker rmi ${IMAGE_NAME}:latest"
        //     }
        // }
        
        // stage ('Trigger CD Job') {
        //     steps {
        //         sh "curl -v -k --user devops:11fc52e17d5d2dc14c59634022bcb40018 -X POST -H 'cache-control: no-cache' -H  'content-type: application/x-www-form-urlencoded' --data 'IMAGE_TAG=${IMAGE_TAG}' 'http://172.30.119.251:8080/job/flaskAp-CD/buildWithParameters?token=gitops-token'"
        //     }
        // }
    }
}
