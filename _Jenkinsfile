pipeline {
    agent {
        label 'dory'
    }
    parameters {
        booleanParam(
            name: 'PUBLISH', defaultValue: false, 
            description: 'Publish docker images on dockerhub')
        string(
            name: 'GPF_BUILD', defaultValue: "-1",
            description: 'gpf build number to use for tagging docker images')
        
        string(
            name: 'GPF_BRANCH', defaultValue: "master",
            description: 'gpf branch to use for building docker images')
    }    
    environment {
        GPF_BUILD="$params.GPF_BUILD"
        GPF_BRANCH="$params.GPF_BRANCH"
        PUBLISH="$params.PUBLISH"
    }
    options { 
        copyArtifactPermission('/iossifovlab/gpf/*,/iossifovlab/gpfjs/*,/iossifovlab/gpf/master,/seqpipe/gpf_documentation/*');
        disableConcurrentBuilds();
    }
    triggers {
        pollSCM('@weekly')
    }
    stages {
        stage ('Start') {
            steps {
                zulipSend(
                    message: "Started build #${env.BUILD_NUMBER} of project ${env.JOB_NAME} (${env.BUILD_URL})",
                    topic: "${env.JOB_NAME}")
            }
        }

        stage ('Build images') {
            steps {
                sh '''
                    echo "WORKSPACE=${WORKSPACE}"
                    cd ${WORKSPACE}
                    ./build_images.sh ${PUBLISH} ${GPF_BUILD} ${GPF_BRANCH}
                '''
            }
        }
    }
    post {
        always {
            zulipNotification(
                topic: "${env.JOB_NAME}"
            )      
        }
        success {

            script {
                def job_result = build job: 'seqpipe/gpf-e2e/master', propagate: true, wait: false, parameters: [
                    string(name: 'GPF_BRANCH', value: "master"),
                    string(name: 'GPF_TAG', value: 'latest')
                ]
            }
        }


    }
}
