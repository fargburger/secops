@Library('mans-apps-shared-library') _

node("h-bldslv-msp-6") {
    try {
        // Wipe the workspace so we are building completely clean
        deleteDir()

        stage ("Get Latest Code") {
            checkout scm

            // Notify GitHub of build in progress
            githubAck('pending')
        }
        stage ("Initialize project's own virtualenv") {
            sh './scripts/virtualenv.sh'
        }
        stage ("Executing Molecule lint") {
            withPythonEnv("${WORKSPACE}/venv/") {
                sh 'molecule lint'
            }
        }
        stage ("Executing Molecule create") {
            withPythonEnv("${WORKSPACE}/venv/") {
                sh 'molecule create'
            }
        }
        stage ("Executing Molecule converge") {
            withPythonEnv("${WORKSPACE}/venv/") {
                withCredentials([string(credentialsId: 'github-admin-token', variable: 'GITHUB_ADMIN_ACCESS_TOKEN')]) {
                    sh 'molecule converge'
                }
            }
        }
        stage ("Executing Molecule idempotence") {
            withPythonEnv("${WORKSPACE}/venv/") {
                withCredentials([string(credentialsId: 'github-admin-token', variable: 'GITHUB_ADMIN_ACCESS_TOKEN')]) {
                    sh 'molecule idempotence'
                }
            }
        }
        stage ("Executing Molecule verify") {
            withPythonEnv("${WORKSPACE}/venv/") {
                withCredentials([string(credentialsId: 'github-admin-token', variable: 'GITHUB_ADMIN_ACCESS_TOKEN')]) {
                    sh 'molecule verify'
                }
            }
        }
        stage("Tag git"){
            if(!isPullRequest()) {

                // Prompt user on how to increment version;
                // then tag repository with new version
                // Note: this cloned repo needs to be updateable (e.g. 'git@github-deploy-keys:cdwlabs/github-deploy-keys.git')
                semanticTag('git@mans-ansible-collection-template:cdwlabs/mans-ansible-collection-template.git')
            }

            // Notify GitHub of build success
            githubAck('success')

        }
    } catch(all) {

        // Notify GitHub of build failure
        githubAck('failure')

        throw all
    }
}
