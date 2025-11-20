pipeline {
    agent any

    triggers {
        githubPush() // Triggered by GitHub webhook on push
    }

    stages {
        stage('Run Only on Main') {
            when {
                branch 'main'
            }
            steps {
                echo "This commit was pushed to the main branch. Running pipeline..."
            }
        }

        stage('Build') {
            when {
                branch 'main'
            }
            steps {
                echo "Building main branch..."
                // Add your build steps here
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                echo "Deploying from main branch..."
                // Add your deploy steps here
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully on main"
        }
        failure {
            echo "Pipeline failed on main"
        }
    }
}
