import base64
import copy
import json
import logging
import os
import ssl
from flask import Flask, request, jsonify

app = Flask(__name__)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Custom annotations to be added to all pods
POD_ANNOTATIONS = {
    "example.com/injected-by": "pod-annotator",
    "example.com/date": "2025-04-24",
    # Add your custom annotations here
}

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)