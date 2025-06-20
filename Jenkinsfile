pipeline{
    agent any

    environment {
        TF_IN_AUTOMATION=true
        TF_CLI_CONFIG_FILE= credentials('tf-creds')
    }

    stages{
        stage('Init'){
            steps{
                sh 'terraform init -no-color'
            }
        }

        stage('Plan'){
            steps{
                sh 'terraform plan -no-color'
            }
        }

        stage('Apply'){
            steps{
                sh 'export AWS_SHARED_CREDENTIALS_FILE=/var/lib/jenkins/aws_creds'
                sh 'terraform apply -auto-approve -no-color'
            }
        }

        stage('Destroy'){
            steps{
                sh 'export AWS_SHARED_CREDENTIALS_FILE=/var/lib/jenkins/aws_creds'
                sh 'terraform destroy -auto-approve -no-color'
            }
        }

    }
}