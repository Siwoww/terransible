pipeline{
    agent any

    environment {
        TF_IN_AUTOMATION=true
        TF_CLI_CONFIG_FILE= credentials('tf-creds')
        AWS_SHARED_CREDENTIALS_FILE='/var/lib/jenkins/aws_creds'
    }


    stages{

        //Select workspace
        stage('Workspace selection'){
            steps{
                sh 'cp /ansible-share/backends/backend-$BRANCH_NAME.tf backend.tf'
                sh 'cat backend.tf|grep -A 2 "name"'
            }
        }

        stage('Validate Workspace'){
            steps{
                input message: "Do you validate this workspace?", ok: "Yes, I do", cancel: "No, I don't"
            }
        }

        //Terraform init
        stage('Init'){
            steps{
                sh 'terraform init -no-color'
            }
        }

        //Terraform plan
        stage('Plan'){
            steps{
                sh 'terraform plan -no-color -var-file="$BRANCH_NAME.tfvars"'
            }
        }

        //Apply validation
        stage('Validate Apply'){
            when{
                beforeInput true
                branch "dev"
            }
            steps{
                input message: "Do you really want to Apply this plan?", ok: "Apply this plan", cancel: "No, don't Apply this plan"
            }
        }

        //Terraform apply
        stage('Apply'){
            steps{
                sh 'terraform apply -auto-approve -no-color -var-file="$BRANCH_NAME.tfvars"'
            }
        }

        stage("Inventory stage"){
            steps{
                sh 'echo "[main]" > /ansible-share/aws_hosts;echo "$(terraform output -json inventory_instances|jq -r \'.[]\')" >> /ansible-share/aws_hosts'
            }
        }

        //Wait for the instance to be created and ready
        stage('EC2 Wait'){
            steps{
                sh 'aws ec2 wait instance-status-ok --instance-ids $(terraform output -json instances_ids|jq -r \'.[]\') --region $(terraform output -json region|jq -r \'.\')'
                /*sh '''aws ec2 wait instance-status-ok \\
                --instance-ids $(terraform show -json|jq -r \'.values\'.\'root_module\'.\'resources[] | select(.type == "aws_instance").values.id\') \\
                --region eu-central-1'''*/
            }
        }

        //Playbook execution validation
        stage('Validate Ansible Playbook'){
            when{
                beforeInput true
                branch "dev"
            }
            steps{
                input message: "Do you want to run Ansible?", ok: "Run Ansible", cancel: "Don't run Ansible"
            }
        }

        //Ansible playbook
        stage('Ansible'){
            steps{
                ansiblePlaybook(inventory: '/ansible-share/aws_hosts', playbook: 'playbooks/main-playbook.yml')
            }
        }

        //Test playbook
        stage('Application Check'){
            steps{
                ansiblePlaybook(inventory: '/ansible-share/aws_hosts', playbook: 'playbooks/test-playbook.yml')
            }
        }

        //Destroy validation
        stage('Validate Destroy'){
            /*when{
                beforeInput true
                branch "dev"
            }*/
            steps{
                input message: "Do you really want to Destroy?", ok: "Destroy", cancel: "Destroy anyway"
            }
        }

        //Terraform destroy
        stage('Destroy'){
            steps{
                sh 'terraform destroy -auto-approve -no-color -var-file="$BRANCH_NAME.tfvars"'
            }
        }
    }

    //Success/failure management
    post{
        success{
            echo 'SUCCESS!'
        }
        failure{
            sh 'terraform destroy -auto-approve -no-color -var-file="$BRANCH_NAME.tfvars"'
        }
        aborted{
            sh 'terraform destroy -auto-approve -no-color -var-file="$BRANCH_NAME.tfvars"'
        }
    }
}