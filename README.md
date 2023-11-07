# Flask App Deployment using GitOps Principles

## Introduction
In ABC organization, one of the most critical challenges hindering software development and delivery process is the lack of end-to-end automation. The absence of a streamlined, automated workflow is impacting organization's efficiency, quality, and competitiveness. The organization currently relies heavily on manual processes and lacks a comprehensive end-to-end automation strategy for software development and delivery pipeline. This has resulted in several key issues:
- Manual, Error-Prone Workflows
- Inconsistent Testing and Quality Assurance
- Slow-Release Cycles
- Limited Scalability

To address these challenges and achieve a more efficient and competitive software development and delivery process, ABC organization has decided to implement end-to-end automation with the help of DevOps Team. The objectives are as follows:
- Streamline Development Pipeline
- Standardize Testing and Quality Assurance
- Accelerate Release Cycles
- Enhance Scalability
- Improve Reliability and Predictability

To address these challenges and achieve the desired state, DevOps Team will embark on a focused initiative to implement end-to-end automation. We will leverage modern tools, methodologies, and best practices to optimize our software development and delivery processes ensuring high-quality with speed and precision.

## TOOLS USED:
**Git:**           Used for version control and source code management.

**Jenkins:**       Used for automating building, testing, and deployment of software.

**Docker:**        Used for containerization and application deployment.

**Kubernetes:**    Used for orchestrating and managing containerized applications.

**GitOps:**        Used for managing and automating the deployment and configuration of infrastructure and applications through version-controlled Git repositories.

![Alt text](static/pic1.png)



### Why GitOps ??
- **Modern Approach:** GitOps is a **modern approach** to managing and automating the deployment and operation of infrastructure and applications, particularly in cloud-native environments. The core idea of GitOps is to use Git repositories as the single source of truth for defining and managing your infrastructure, application configurations, and deployment processes. 

- **Continuous Synchronization:** GitOps tools continuously monitor the Git repository for changes and synchronize the state of the system with the declared state.

- **Multi-Environment Support:** GitOps practices can be used across different environments, from development to production. The same Git repository can define configurations for various environments, making it easy to replicate and maintain consistent environments

- **Collaboration:** GitOps encourages collaboration among development and operations teams. By storing Kubernetes configurations in Git repositories, you can use Git's collaboration features, including pull requests and code reviews, to ensure high-quality configurations.

## Installation
**Jenkins**
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y

# Password to log in Jenkins
sudo cat /var/lib/jenkins/secrets/initialAdminPassword```
```


## Pipeline 
I have created two pipelines in Jenkins. One for Continuous Integration(CI) and another for [Continuous Deployment](https://github.com/saeedalig/k8s-manifest.git)
. CI pipeline ended with triggering the CD pileline. To keep the project simple, I have added few stages in CD pipeline that only update the IMAGE_TAG coming from the CI pipeline in the deployment manifest and then push it to the GitHub to get the latest changes reflected in Kubernetes Cluster.  


### Pipeline Script
**Continuos Integration**

```
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
        
        stage('Push Docker Image'){
            steps {
                script{
                    docker.withRegistry('', REGISTRY_CREDS ){
                        docker_image.push("${BUILD_NUMBER}")
                        docker_image.push('latest')
                    }
                }
            }
        }
        
        stage('Delete Docker Images'){
            steps {
                sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker rmi ${IMAGE_NAME}:latest"
            }
        }
        
        stage ('Trigger CD Job') {
            steps {
                sh "curl -v -k --user devops:11fc52e17d5d2dc14c59634022bcb40018 -X POST -H 'cache-control: no-cache' -H  'content-type: application/x-www-form-urlencoded' --data 'IMAGE_TAG=${IMAGE_TAG}' 'http://172.30.119.251:8080/job/flaskAp-CD/buildWithParameters?token=gitops-token'"
            }
        }
    }
}
```
The last stage will trigger the second pipeline (script mentioned below)

**Continuos Deployment**
```
pipeline{
    agent any
    
    environment {
        APP_NAME = "flask-app"
    }


	
    stages {
	
        stage('Clean Workspace'){
            steps{
                cleanWs()
            }
        }
		
        stage('Git Checkout'){
            steps{
                git branch: 'main', url: 'https://github.com/saeedalig/k8s-manifest.git'
            }
        }
        
        stage('Update k8s deployment file'){
            steps {
                sh "cat deployment.yaml"
                sh "sed -i 's/${APP_NAME}.*/${APP_NAME}:${IMAGE_TAG}/g' deployment.yaml"                
                sh "cat deployment.yaml"
            }
        }
        
        stage('Push the changed deployment file to GitHub') {
            steps {
                script {
                    sh """
                    git config --global user.name "saeed"
                    git config --global user.email "saeed@gmail.com"
                    git add deployment.yaml
                    git commit -m 'Updated the deployment file'
                    """
                    withCredentials([usernamePassword(credentialsId: 'github', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh 'git remote set-url origin https://$USER:$PASS@github.com/saeedalig/k8s-manifest.git'
                        sh 'git push origin main'
                    }
                }
            }
        }
    }
}
```

![Alt text](static/pic2.png)
![Alt text](static/pic3.png)

![Alt text](static/pic4.png)







