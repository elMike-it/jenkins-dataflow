pipeline {
    agent any
    environment {
        PROJECT_ID = 'test-interno-trendit'
        SERVICE_NAME = 'mike-dataflow-service'
        REGION = 'us-central1' // e.g., us-central1
        GCS_BUCKET = 'jenkins-dataflow' // Nombre del bucket de GCS
        JOB_NAME = 'jenkins-dataflow-upper' // Nombre del job en Dataflow
        GCP_KEYFILE = credentials('gcp-sa-jenkins-dataflow') // Credencial configurada en Jenkins
        IMAGE_NAME = "gcr.io/${PROJECT_ID}/${SERVICE_NAME}"
    }
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('Authenticate with GCP') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'gcp-sa-jenkins-dataflow', variable: 'GCP_KEYFILE_PATH')]) {
                        sh """
                        gcloud auth activate-service-account --key-file=${GCP_KEYFILE_PATH}
                        gcloud config set project ${PROJECT_ID}
                        gcloud auth list
                        """
                    }
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    docker build -t ${IMAGE_NAME} .
                    """
                }
            }
        }


        stage('Python with Docker') {
            agent {
                docker {
                    image "${IMAGE_NAME}" // Imagen personalziada
                    //args '-u root' // Permite ejecutar comandos como usuario root
                    args '--entrypoint=""'// Esto elimina conflictos de ENTRYPOINT
                    reuseNode true
                }
            }
            stages {
                stage('Setup Python Environment') {
                    steps {
                        withPythonEnv('python3') {
                            sh """
                            python --version
                            pip install --upgrade pip setuptools
                            pip install -r requirements.txt
                            """
                        }
                    }
                }
                stage('Upload Python Script to GCS') {
                    steps {
                        sh """
                        gsutil cp main.py gs://${GCS_BUCKET}/scripts/
                        """
                    }
                }
                stage('Run Dataflow Job') {
                    steps {
                        sh """
                        gcloud dataflow jobs run ${JOB_NAME} \
                        --gcs-location gs://${GCS_BUCKET}/scripts/main.py \
                        --region ${REGION} \
                        --staging-location gs://${GCS_BUCKET}/staging/ \
                        --parameters input=gs://${GCS_BUCKET}/input/input.txt,output=gs://${GCS_BUCKET}/output/output.txt
                        """
                    }
                }

            }
        }

        
    }
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Dataflow job executed successfully!'
        }
        failure {
            echo 'Dataflow job failed.'
        }
    }
}
