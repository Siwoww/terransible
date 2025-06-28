pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = true
        TF_CLI_CONFIG_FILE = credentials('tf-creds')
        AWS_SHARED_CREDENTIALS_FILE = '/var/lib/jenkins/aws_creds'
    }

    parameters {
        choice(name: 'env', choices: ['dev', 'main'], description: 'Ambiente:')
    }

    stages {

        stage('Workspace selection') {
            steps {
                sh "cp /ansible-share/backends/backend-${params.env}.tf backend.tf"
                sh "cat backend.tf | grep -A 2 'name'"
            }
        }

        stage('Validate Workspace') {
            steps {
                input message: "Do you validate this workspace?", ok: "Yes, I do", cancel: "No, I don't"
            }
        }

        stage('Init') {
            steps {
                sh 'terraform init -no-color'
            }
        }

        stage('Plan') {
            steps {
                sh "terraform plan -no-color -var-file='${params.env}.tfvars'"
            }
        }

        stage('Validate Apply') {
            when {
                beforeInput true
                expression { params.env == "dev" }
            }
            steps {
                input message: "Do you really want to Apply this plan?", ok: "Apply this plan", cancel: "No, don't Apply this plan"
            }
        }

        stage('Apply') {
            steps {
                sh "terraform apply -auto-approve -no-color -var-file='${params.env}.tfvars'"
            }
        }

        stage("Inventory stage") {
            steps {
                sh """echo '[main]' > '/ansible-share/aws_hosts-${params.env}'
echo \$(terraform output -json inventory_instances | jq -r '.[]') >> '/ansible-share/aws_hosts-${params.env}'"""
            }
        }

        stage('EC2 Wait') {
            steps {
                sh """aws ec2 wait instance-status-ok \
--instance-ids \$(terraform output -json instances_ids | jq -r '.[]') \
--region \$(terraform output -json region | jq -r '.')"""
            }
        }

        stage('Validate Ansible Playbook') {
            when {
                beforeInput true
                expression { params.env == "dev" }
            }
            steps {
                input message: "Do you want to run Ansible?", ok: "Run Ansible", cancel: "Don't run Ansible"
            }
        }

        stage('Ansible') {
            steps {
                ansiblePlaybook(
                    inventory: "/ansible-share/aws_hosts-${params.env}",
                    playbook: "playbooks/main-playbook.yml"
                )
            }
        }

        stage('Application Check') {
            steps {
                ansiblePlaybook(
                    inventory: "/ansible-share/aws_hosts-${params.env}",
                    playbook: "playbooks/test-playbook.yml"
                )
            }
        }

        stage('Validate Destroy') {
            steps {
                input message: "Do you really want to Destroy?", ok: "Destroy", cancel: "Destroy anyway"
            }
        }

        stage('Destroy') {
            steps {
                sh "terraform destroy -auto-approve -no-color -var-file='${params.env}.tfvars'"
                sh "rm -f /ansible-share/aws_hosts-${params.env}"
            }
        }
    }

    post {
        success {
            echo 'SUCCESS!'
        }
        failure {
            script {
                if (params.env == "dev") {
                    sh "terraform destroy -auto-approve -no-color -var-file='${params.env}.tfvars'"
                }
            }
        }
        aborted {
            script {
                if (params.env == "dev") {
                    sh "terraform destroy -auto-approve -no-color -var-file='${params.env}.tfvars'"
                }
            }
        }
    }
}
