from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello, %s!" % os.environ['NAME']

@app.route('/health')
def liveness():
    return "I'm liveness"

@app.route('/ready')
def readiness():
    return "I'm readiness"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
