pipeline{
    agent any
    stages{
        stage('Init'){
            steps{
                sh 'ls'
                sh 'export TF_IN_AUTOMATION=true'
                sh 'terraform init -no-color'
            }
        }

        stage('Plan'){
            steps{
                sh 'export TF_IN_AUTOMATION=true'
                sh 'terraform plan -no-color'
            }
        }

        stage('Plan'){
            steps{
                sh 'export TF_IN_AUTOMATION=true'
                sh 'export AWS_SHARED_CREDENTIALS_FILE=/var/lib/jenkins/aws_creds'
                sh 'terraform apply -auto-approve -no-color'
            }
        }

    }
}