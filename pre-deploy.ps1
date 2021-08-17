Set-Location .\deploy\

terraform init

az login

terraform apply -auto-approve -json