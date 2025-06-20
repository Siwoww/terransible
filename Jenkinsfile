pipeline{
    agent any

    environment {
        TF_IN_AUTOMATION=true
        TF_CLI_CONFIG_FILE= credentials('tf-creds')
        AWS_SHARED_CREDENTIALS_FILE='/var/lib/jenkins/aws_creds'
    }

    
    stages{

        //Terraform init
        stage('Init'){
            steps{
                sh 'terraform init -no-color'
            }
        }

        //Terraform plan
        stage('Plan'){
            steps{
                sh 'terraform plan -no-color'
            }
        }

        //Apply validation
        stage('Validate Apply'){
            input{
                message: "Do you really want to Apply this plan?", ok: "Apply this plan", cancel: "No, don't Apply this plan"
            }
        }

        //Terraform apply
        stage('Apply'){
            steps{
                sh 'terraform apply -auto-approve -no-color'
            }
        }

        //Wait for the instance to be created and ready
        stage('EC2 Wait'){
            steps{
                sh 'aws ec2 wait instance-status-ok --region eu-central-1'
            }
        }

        //Ansible playbook
        stage('Ansible'){
            steps{
                ansiblePlaybook(inventory: '/ansible-share/aws_hosts', playbook: 'playbooks/main-playbook.yml')
            }
        }

        //Terraform destroy
        stage('Destroy'){
            steps{
                sh 'terraform destroy -auto-approve -no-color'
            }
        }

    }
}