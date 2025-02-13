# Sample helm application running on EKS

## Requirements

* [AWS cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
* [Docker](https://www.docker.com/)
* [Terraform](https://www.terraform.io/)
* [TFLint](https://github.com/terraform-linters/tflint) terraform linter (optional)
* [Trivy](https://trivy.dev) security scanner
* [jq](https://jqlang.org/) command-line JSON processor
* A valid public domain declared in the AWS Route53 dns

## Terraform

Optional: check terraform code

```bash
tflint --chdir=tf --recursive
```

### AWS network infrastructure

Define the terraform s3 backend (we are using [S3-native state locking](https://github.com/hashicorp/terraform/pull/35661)):

```bash
cat << EOT > tf/sample/network/environment/dev/backend.tfvars
bucket       = "<bucket name>"
key          = "<tf state file>""
use_lockfile = true
region       = "<bucket region>"
EOT
```

Review the `environment/dev/terraform.tfvars`

Create the network infrastructure:

```bash
cd tf/sample/network
terraform init -backend-config=environment/dev/backend.tfvars
terraform validate
terraform plan -var-file=environment/dev/terraform.tfvars
terraform apply -var-file=environment/dev/terraform.tfvars
```

### AWS EKS

Define the terraform s3 backend:

```bash
cd ../eks
cat << EOT > environment/dev/backend.tfvars
bucket       = "<bucket name>"
key          = "<tf state file>""
use_lockfile = true
region       = "<bucket region>"
EOT
```

Review the `environment/dev/terraform.tfvars`

Create the EKS:

```bash
export APP_DNS_NAME=<your dns app name>
export MY_DOMAIN_HOSTED_ZONE_ID=<your app domain hosted zone id>
export TF_VAR_route53="{ dns_name = \"$APP_DNS_NAME\", hosted_zone = \"$MY_DOMAIN_HOSTED_ZONE_ID\" }"
terraform init -backend-config=environment/dev/backend.tfvars
terraform validate
terraform plan -var-file=environment/dev/terraform.tfvars
terraform apply -var-file=environment/dev/terraform.tfvars
```

## Flask application

The docker image contains a sample [flask](https://flask.palletsprojects.com) application with 3 routes:
* the default route `/` that return the string `Hello` plus the value of the environment variable `NAME`
* the route `/health` used by the k8s _liveness_ probe ( mock )
* the route `/ready` used by the k8s _readiness_ probe ( mock )

### Testing locally the flask application

```bash
cd ../../../application/docker
python3 -m venv .venv
source .venv/bin/activate 
pip3 install -r requirements.txt
export NAME=World
python3 hello.py
```

In another terminal check the routes:

```bash
curl -si http://localhost:8080
curl -si http://localhost:8080/health
curl -si http://localhost:8080/ready
```

Press _Ctrl-C_ to stop flask application and type `deactivate` to exit from python virtual environment.

### Build and push docker image

```bash
export AWS_ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`
export AWS_REGION=`grep region ../../tf/sample/eks/environment/dev/terraform.tfvars | cut -d"\"" -f 2` # Get region from terraform vars
export IMG_TAG=`grep version Dockerfile | cut -d"=" -f 2 | sed 's/"//g'`
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
docker build --platform linux/amd64 -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/hello:$IMG_TAG-amd64 .
docker build --platform linux/arm64 -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/hello:$IMG_TAG-arm64 .
trivy image $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/hello:$IMG_TAG-amd64
trivy image $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/hello:$IMG_TAG-arm64
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/hello:$IMG_TAG-amd64
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/hello:$IMG_TAG-arm64
docker manifest create --amend $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/hello:$IMG_TAG \
$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/hello:$IMG_TAG-amd64 \
$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/hello:$IMG_TAG-arm64

docker manifest inspect $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/hello:$IMG_TAG
docker manifest push -p $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/hello:$IMG_TAG
```

## Helm application

The Helm application is a sample deployment using the above flask application. The routes are exposed using an ingress controller (_AWS Load Balancer Controller_).

### Build helm package

Test the chart using mock values:

```bash
cd ../helm
helm template --set ingress.certificate_arn=fake-arn --set ingress.host=fake-host --set image.repository=myrepo/image:tag myapp
```

### Build and push the helm package

```bash
helm package myapp
helm push myapp-`grep version myapp/Chart.yaml | cut -d" " -f 2 | sed 's/"//g'`.tgz oci://$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/
```

## Deploy helm application

Get the kubeconfig:

```bash
cd ../../
export K8S_NAME=`grep project_name tf/sample/eks/environment/dev/terraform.tfvars | cut -d"=" -f 2 | sed 's/[" ]//g'`
aws eks update-kubeconfig --region $AWS_REGION --name $K8S_NAME --kubeconfig ~/.kube/$K8S_NAME --alias $K8S_NAME
```

Deploy:

```bash
export KUBECONFIG=~/.kube/eks-helm
export SSM_PREFIX=`grep project_name tf/sample/eks/environment/dev/terraform.tfvars | cut -d"=" -f 2 | sed 's/[" ]//g'`
export MY_PUBLIC_IP=`curl -s ifconfig.me` # Limit access to the application
export DOCKER_TAG=`grep version application/docker/Dockerfile | cut -d"=" -f 2 | sed 's/"//g'`
export HELM_TAG=`grep version application/helm/myapp/Chart.yaml | cut -d" " -f 2 | sed 's/"//g'`
export CERTIFICATE_ARN=`aws ssm get-parameters --names "/$SSM_PREFIX/certificate/$APP_DNS_NAME/id" --query "Parameters[*].Value" --output text`
helm upgrade myapp --cleanup-on-fail \
--install oci://$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/myapp \
--version $HELM_TAG \
--namespace myapp \
--create-namespace \
--set helloName=World \
--set ingress.host=$APP_DNS_NAME \
--set ingress.certificate_arn=$CERTIFICATE_ARN \
--set ingress.inboundCidrs=$MY_PUBLIC_IP/32 \
--set image.repository=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/hello \
--set image.tag=$DOCKER_TAG
```

### Add DNS record

```bash
export MY_ALB_DNS_NAME=`aws elbv2 describe-load-balancers --names myapp-albc --query 'LoadBalancers[*].[DNSName]' --output text`
export LB_HOSTED_ZONE_ID=Z35SXDOTRQ7X7K # us-east-1 mock - todo: get id from aws cli
cat << EOT > dns_record.json
{  
  "Comment": "Creating Alias resource record sets in Route 53",
    "Changes": [
    {
    "Action": "UPSERT",
    "ResourceRecordSet": {
        "Name": "${APP_DNS_NAME}",
        "Type": "A",
        "AliasTarget": {
            "HostedZoneId": "${LB_HOSTED_ZONE_ID}",
            "DNSName": "dualstack.${MY_ALB_DNS_NAME}.",
            "EvaluateTargetHealth": false
        }
      }
    }
  ]
}
EOT
aws route53 change-resource-record-sets --hosted-zone-id $MY_DOMAIN_HOSTED_ZONE_ID --change-batch file://./dns_record.json
```

## Test the application

```bash
export READY=false
export COUNT=0
while [ "$READY" = "false" ] && [ "$COUNT" -lt 10 ]
do
  nslookup $APP_DNS_NAME | grep "No answer" > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
    export READY=true
  else
    COUNT=$((COUNT+1))
    echo -n "."
    sleep 5
  fi
done
echo
if [ "$READY" = "false" ]
then
  echo "Cannot resolve $APP_DNS_NAME dns name"
  exit 1
fi
curl -si https://$APP_DNS_NAME && echo
```

## Cleanup

Remove DNS record:

```bash
sed -i '' 's/UPSERT/DELETE/' dns_record.json
aws route53 change-resource-record-sets --hosted-zone-id $MY_DOMAIN_HOSTED_ZONE_ID --change-batch file://./dns_record.json
```

Delete the application (required in order to delete the load balancer):

```bash
helm uninstall -n myapp myapp
```

Wait for load balancer to be deleted:

```bash
export READY=false
export COUNT=0
while [ "$READY" = "false" ] && [ "$COUNT" -lt 10 ]
do
  kubectl -n myapp get ingress myapp-ingress > /dev/null 2>&1
  if [ $? -eq 1 ]
  then
    export READY=true
  else
    COUNT=$((COUNT+1))
    echo -n "."
    sleep 5
  fi
done
echo
if [ "$READY" = "false" ]
then
  echo "Unable to delete load balancer myapp-ingress"
  exit 1
fi
```

Delete the images in the ECR:

```bash
export IMG_DIGEST=`aws ecr list-images --repository-name hello --query 'imageIds[*].imageDigest' --output text | sed 's/sha256/imageDigest=sha256/g'`
aws ecr batch-delete-image --repository-name hello --image-ids $IMG_DIGEST

export IMG_DIGEST=`aws ecr list-images --repository-name myapp --query 'imageIds[*].imageDigest' --output text | sed 's/sha256/imageDigest=sha256/g'`
aws ecr batch-delete-image --repository-name myapp --image-ids $IMG_DIGEST
```

Delete the EKS:

# terraform output ecr_repos

```bash
cd tf/sample/eks
export TF_VAR_route53="{ dns_name = \"$APP_DNS_NAME\", hosted_zone = \"$MY_DOMAIN_HOSTED_ZONE_ID\" }"
terraform destroy -var-file=environment/dev/terraform.tfvars -auto-approve
rm -rf .terraform.lock.hcl
rm -rf .terraform
```

Delete the network infrastructure:

```bash
cd ../network
terraform destroy -var-file=environment/dev/terraform.tfvars -auto-approve
rm -rf .terraform.lock.hcl
rm -rf .terraform
cd ../../../
```

Remove the terraform state files in the s3 bucket.

## References

[Getting Started with the Python Chainguard Image](https://edu.chainguard.dev/chainguard/chainguard-images/getting-started/python/)

[AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/)

[Security policies for your Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/describe-ssl-policies.html)

[Amazon EKS recommended maximum Pods for each Amazon EC2 instance type](https://docs.aws.amazon.com/eks/latest/userguide/choosing-instance-type.html#determine-max-pods)

[Amazon VPC CNI versions](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html#vpc-cni-latest-available-version)

[CoreDNS versions](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html#coredns-versions)

[kube-proxy versions](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html#kube-proxy-versions)

[Pushing a Helm chart to an Amazon ECR private repository](https://docs.aws.amazon.com/AmazonECR/latest/userguide/push-oci-artifact.html)

[Pushing a multi-architecture image to an Amazon ECR private repository](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-multi-architecture-image.html)

[Route 53 Hosted Zone ID about load balancer](https://docs.aws.amazon.com/general/latest/gr/elb.html#elb_region)
