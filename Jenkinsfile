pipeline {
    agent any
    environment {
        PROJECT_ID = 'test-interno-trendit'
        SERVICE_NAME = 'mike-dataflow-service'
        REGION = 'us-central1' // e.g., us-central1
        GCS_BUCKET = 'jenkins-dataflow' // Nombre del bucket de GCS
        JOB_NAME = 'jenkins-dataflow-upper' // Nombre del job en Dataflow
        GCP_KEYFILE = credentials('gcp-sa-jenkins-dataflow') // Credencial configurada en Jenkins
        TEMPLATE_PATH = "gs://${GCS_BUCKET}/templates/template.json"
        DOCKER_IMAGE = "gcr.io/${PROJECT_ID}/${SERVICE_NAME}"
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
        stage('Upload Python Script to GCS') {
            steps {
                sh """
                gsutil cp main.py gs://${GCS_BUCKET}/scripts/
                """
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    docker build -t ${DOCKER_IMAGE} .
                    """
                }
            }
        }
        stage('Run Pipeline') {
            agent {
                docker {
                    image "${DOCKER_IMAGE}"
                    args '--entrypoint=""'// Esto elimina conflictos de ENTRYPOINT                }
            }
            stages {
                stage('Setup Python Environment') {
                    steps {
                        withEnv(["HOME=${env.WORKSPACE}"]) {
                            sh """
                            python3 --version
                            pip install --upgrade pip setuptools
                            pip install -r requirements.txt
                            """
                        }
                    }
                }
                stage('Create Dataflow Template') {
                    steps {
                        withEnv(["HOME=${env.WORKSPACE}"]) {
                            sh """
                            python3 main.py --runner DataflowRunner \
                                --project ${PROJECT_ID} \
                                --region ${REGION} \
                                --template_location gs://jenkins-dataflow-temps/template \
                                --temp_location gs://jenkins-dataflow-temps/temp
                            """
                        }
                    }
                }
            }
        }
        stage('Run Dataflow Job') {
            steps {
                sh """
                gcloud dataflow jobs run ${JOB_NAME} \
                --gcs-location gs://${GCS_BUCKET}/scripts/main.py \
                --region ${REGION} \
                --gcs-location=gs://jenkins-dataflow-temps/template \
                --parameters input=gs://${GCS_BUCKET}/input/input.txt,output=gs://${GCS_BUCKET}/output/output.txt
                """
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
