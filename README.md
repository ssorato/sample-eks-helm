# Sample helm application running on EKS

## Requirements

* [AWS cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
* [Docker](https://www.docker.com/)

## Flask application

The docker image contains a sample [flask](https://flask.palletsprojects.com) application with 3 routes:
* the default route `/` that return the string "hello" plus the value of the environment variable `NAME`
* the route `/health` used by the k8s _liveness_ probe ( mock )
* the route `/ready` used by the k8s _readiness_ probe ( mock )

### Testing locally the flask application

```bash
cd application/docker
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

Press _Ctrl-C_ to stop flask application

## Helm application

The Helm application is a sample deployment using the above flask application. The routes are exposed using an ingress controller (_AWS Load Balancer Controller_).

### Build helm package

Test the chart using mock values:

```bash
cd ../helm
helm template --set ingress.certificate_arn=fake-arn --set ingress.host=fake-host --set image.repository=myrepo/image:tag myapp
```

Build the package

```bash
helm package myapp
```

## References

[Getting Started with the Python Chainguard Image](https://edu.chainguard.dev/chainguard/chainguard-images/getting-started/python/)

[AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/)

[Security policies for your Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/describe-ssl-policies.html)
