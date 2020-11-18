pipeline {
	agent any

	environment {
    GOOGLE_PROJECT_ID = 'dsc-fptu-hcmc-orientation'
  }

	stages {
		stage('Install dependencies') {
			steps {
        script {
          if (fileExists('node_modules')) {
            sh 'rm -rf node_modules'
          }

          if (fileExists('rm package-lock.json')) {
            sh 'rm package-lock.json'
          }
        }
        sh '''
          echo "PATH = ${PATH}"
          node --version
          npm --version
          npm cache clean --force
          npm install
          echo "Install dependencies successfully!"
        '''
			}
		}

		stage('Bundle Angular application') {
			steps {
				sh '''
          echo "BUILD NUMBER = $BUILD_NUMBER"
          ./node_modules/.bin/ng build --aot --prod
          echo ""
        '''
			}
    }

		stage('Deploy to production') {
			steps {
        withCredentials([file(credentialsId: 'google-application-credentials-secret-file', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
          sh '''
            input "Deploy to production?"
            gcloud --version
            echo "GCP credentails: $GOOGLE_APPLICATION_CREDENTIALS"
            gcloud config set project $GOOGLE_PROJECT_ID
            gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS
            gcloud config list
            cp app.yaml dist/app.yaml
            cd dist
            gcloud app deploy --version=v01
            echo "Deployed to Google Compute Engine"
          '''
        }
      }
		}
	}
}