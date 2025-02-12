# Sample helm application running on EKS

## Requirements

* [AWS cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
* [Docker](https://www.docker.com/)

## Docker image

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

## References

[Getting Started with the Python Chainguard Image](https://edu.chainguard.dev/chainguard/chainguard-images/getting-started/python/)
