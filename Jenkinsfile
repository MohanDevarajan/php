pipeline {
    agent any

    environment {
        TARGET_IP = '192.168.56.11'
        INVENTORY_FILE = '/home/jenkins/hosts.ini'
        PLAYBOOK_FILE = '/home/jenkins/install_docker.yaml'
        GIT_REPO = 'https://github.com/MohanDevarajan/php.git'
        DOCKER_IMAGE = 'php-site:latest'
        CONTAINER_NAME = 'php_site'
    }

    triggers {
        githubPush() // Triggered by GitHub webhook on push
    }

    stages {
        stage('Run Only on Main Branch') {
            when {
                branch 'main'
            }
            steps {
                echo "Commit pushed to 'main'. Proceeding with pipeline..."
            }
        }

        stage('Job1: Install Puppet Agent on Test') {
            when {
                branch 'main'
            }
            steps {
                sh '''
                    ssh -o StrictHostKeyChecking=no jenkins@${TARGET_IP} '
                        if ! dpkg -s puppet-agent >/dev/null 2>&1; then
                            echo "Puppet Agent not found, installing..."
                            sudo apt update &&
                            sudo apt install -y wget gnupg &&
                            wget -q https://apt.puppet.com/puppet7-release-$(lsb_release -cs).deb &&
                            sudo dpkg -i puppet7-release-$(lsb_release -cs).deb &&
                            sudo apt update &&
                            sudo apt install -y puppet-agent &&
                            sudo systemctl enable puppet &&
                            sudo systemctl start puppet
                        else
                            echo "Puppet Agent already installed."
                            if ! systemctl is-active --quiet puppet; then
                                echo "Puppet service is installed but not running. Starting service..."
                                sudo systemctl start puppet
                            else
                                echo "Puppet service is already running."
                            fi
                        fi
                    '
                '''
            }
        }

        stage('Job2: Install Docker via Ansible') {
            when {
                branch 'main'
            }
            steps {
                sh '''
                    ansible-playbook -i ${INVENTORY_FILE} ${PLAYBOOK_FILE}
                '''
            }
        }

        stage('Job3: Deploy PHP Docker App') {
            when {
                branch 'main'
            }
            steps {
                sh """
                    ssh -o StrictHostKeyChecking=no jenkins@${TARGET_IP} '
                        set -e
                        [ -d /tmp/php-site ] && rm -rf /tmp/php-site
                        git clone ${GIT_REPO} /tmp/php-site
                        cd /tmp/php-site
                        docker build -t ${DOCKER_IMAGE} .

                        if [ \$(docker ps -a -q -f name=^/${CONTAINER_NAME}\$) ]; then
                            echo "Removing existing container: ${CONTAINER_NAME}"
                            docker rm -f ${CONTAINER_NAME}
                        fi

                        docker run -d --name ${CONTAINER_NAME} -p 8561:80 ${DOCKER_IMAGE}
                    '
                """
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed. Attempting to clean up container on target host...'
            sh '''
                ssh -o StrictHostKeyChecking=no jenkins@${TARGET_IP} '
                    docker rm -f ${CONTAINER_NAME} || true
                '
            '''
        }
    }
}
