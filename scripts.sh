git clone https://github.com/kerv17/CloudTP2
cd CloudTP2
git checkout test

ACCESS_KEY="$1"
SECRET_KEY="$2"
TOKEN="$3"

echo "Terraforming Infra..."

cd Terraform

export TF_VAR_access_key="$ACCESS_KEY"
export TF_VAR_secret_key="$SECRET_KEY"
export TF_VAR_token="$TOKEN"

terraform init
terraform apply -auto-approve

echo "Starting wordcount docker container"
docker build -t wordcount .
docker run -d --name wordcount wordcount
cd ..

cd Friends
echo "Starting friends docker container"
docker build -t friends .
docker run -d --name friends friends