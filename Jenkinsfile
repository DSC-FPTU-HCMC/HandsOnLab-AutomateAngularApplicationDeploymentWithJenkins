pipeline {
  agent {
    docker {
      image 'node:15-alpine'
      args '-p 3000:3000'
    }
  }
  environment {
    CI = 'true'
  }
  stages {
    stage('Build') {
      steps {
        sh 'npm install'
      }
    }
    stage('Test') {
      steps {
        sh 'echo Test done!'
      }
    }
    stage('Deliver') {
      steps {
        input message: 'Deploy to production? (Click "Proceed" to continue)'
        sh 'gsutil -m rsync -r ./dist gs://<your-bucket-name>/static'
      }
    }
  }
}
