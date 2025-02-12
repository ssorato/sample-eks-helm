# https://edu.chainguard.dev/chainguard/chainguard-images/getting-started/python/

FROM cgr.dev/chainguard/python:latest-dev AS builder
ENV LANG=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/app/venv/bin:$PATH"
WORKDIR /app
RUN python -m venv /app/venv
COPY requirements.txt .
RUN pip install --no-cache-dir --no-cache-dir -r requirements.txt


FROM cgr.dev/chainguard/python:latest
LABEL vendor="Tabajara Organizations"
LABEL version="0.0.1"

ENV PYTHONUNBUFFERED=1
ENV PATH="/venv/bin:$PATH"
WORKDIR /app
COPY hello.py ./
COPY --from=builder /app/venv /venv

EXPOSE 8080 
ENTRYPOINT [ "python", "/app/hello.py" ]
