
# AWS ETL (raw → curated) with Terraform + Glue + Jenkins

Custom for:
- AWS Account ID: **074682456135**
- Region: **us-east-2**
- Repo: **https://github.com/svelaga2704/TerraForm-ETL-AWS.git**, branch **main**

## Structure
- `data/raw/` — your 3 CSVs (already included)
- `glue_scripts/join_to_curated.py` — reads 3 CSVs, joins, writes Parquet to `curated/joined/`
- `terraform/` — creates 2 buckets (raw/curated), uploads CSVs + script, IAM role, Glue job
- `Jenkinsfile` — Linux agent version
- `Jenkinsfile.windows` — Windows agent version

## Run Terraform locally
```bash
terraform -chdir=terraform init
terraform -chdir=terraform plan -out=tfplan
terraform -chdir=terraform apply -auto-approve tfplan
terraform -chdir=terraform output
```

## Run the Glue job manually (optional)
```bash
aws glue start-job-run --job-name join-to-curated
```

## Use in Jenkins (no webhooks; manual builds)
Create a Pipeline job and paste **one** of these files into the Pipeline script box:
- For Linux agent: open `Jenkinsfile` and paste it
- For Windows agent: open `Jenkinsfile.windows` and paste it

Make sure Jenkins has AWS credentials with ID **aws-access-key-id**.
