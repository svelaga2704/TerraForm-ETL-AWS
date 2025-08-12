
pipeline {
  agent any
  environment {
    AWS_DEFAULT_REGION     = 'us-east-2'
    REPO_URL               = 'https://github.com/svelaga2704/TerraForm-ETL-AWS.git'
    BRANCH                 = 'main'
    GITHUB_CREDENTIALS_ID  = ''  // leave empty if repo is public
  }
  stages {
    stage('Checkout') {
      steps {
        script {
          if (env.GITHUB_CREDENTIALS_ID?.trim()) {
            git credentialsId: env.GITHUB_CREDENTIALS_ID, branch: env.BRANCH, url: env.REPO_URL
          } else {
            git branch: env.BRANCH, url: env.REPO_URL
          }
        }
      }
    }
    stage('Use AWS credentials') {
      steps {
        withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws-access-key-id',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh 'aws sts get-caller-identity || true'
        }
      }
    }
    stage('Terraform init/plan/apply') {
      steps {
        sh '''
          set -e
          terraform -chdir=terraform init
          terraform -chdir=terraform plan -out=tfplan
          terraform -chdir=terraform apply -auto-approve tfplan
        '''
      }
    }
    stage('Run Glue Job') {
      steps {
        sh '''
          set -euo pipefail
          JOB_NAME=$(terraform -chdir=terraform output -raw glue_job_name)
          echo "Starting Glue job: $JOB_NAME"
          RUN_ID=$(aws glue start-job-run --job-name "$JOB_NAME" --query 'JobRunId' --output text)
          while true; do
            STATUS=$(aws glue get-job-run --job-name "$JOB_NAME" --run-id "$RUN_ID" --query 'JobRun.JobRunState' --output text)
            echo "Status: $STATUS"
            case "$STATUS" in
              SUCCEEDED) break ;;
              FAILED|ERROR|STOPPED) echo "Job ended: $STATUS"; exit 1 ;;
            esac
            sleep 20
          done
        '''
      }
    }
  }
  post { always { archiveArtifacts artifacts: '**/terraform.tfstate', allowEmptyArchive: true } }
}
