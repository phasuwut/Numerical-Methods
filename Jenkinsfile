pipeline {
	agent any

	environment {
		IMAGE_NAME = "numerical-methods"
		IMAGE_TAG = "${env.BUILD_NUMBER}"
	}

	stages {
		stage('Checkout') {
			steps {
				checkout scm
			}
		}

		stage('Build Docker Image') {
			steps {
				sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
			}
		}
	}

	post {
		always {
			sh "docker image prune -f"
		}
	}
}
