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

@app.route('/mutate', methods=['POST'])
def mutate():
    request_info = request.json
    
    logger.info("Received admission request")
    
    # Extract the request body from AdmissionReview
    if not request_info.get('request', None):
        return jsonify({"apiVersion": "admission.k8s.io/v1", "kind": "AdmissionReview", "response": {"allowed": True}}), 200
    
    request_body = request_info['request']
    
    # Skip if it's not a pod
    if request_body.get('kind', {}).get('kind') != 'Pod':
        return jsonify({
            "apiVersion": "admission.k8s.io/v1",
            "kind": "AdmissionReview",
            "response": {
                "uid": request_body.get('uid'),
                "allowed": True
            }
        }), 200
    
    # Decode the pod JSON
    pod = request_body.get('object', {})

    # Create a list of patches to apply
    patches = []
    
    # Check if annotations exist and create if not
    if 'annotations' not in pod.get('metadata', {}):
        patches.append({
            "op": "add",
            "path": "/metadata/annotations",
            "value": {}
        })
    
    # Add our custom annotations
    for key, value in POD_ANNOTATIONS.items():
        escaped_key = key.replace("~", "~0").replace("/", "~1")
        patches.append({
            "op": "add",
            "path": f"/metadata/annotations/{escaped_key}",
            "value": value
        })
    
    # Create the admission response
    admission_response = {
        "apiVersion": "admission.k8s.io/v1",
        "kind": "AdmissionReview",
        "response": {
            "uid": request_body.get('uid'),
            "allowed": True
        }
    }
    
    # Add the patch if there are changes to make
    if patches:
        patch_bytes = json.dumps(patches).encode()
        admission_response["response"]["patchType"] = "JSONPatch"
        admission_response["response"]["patch"] = base64.b64encode(patch_bytes).decode()
    
    logger.info(f"Sending response with patches: {patches}")
    
    return jsonify(admission_response), 200

if __name__ == '__main__':
    cert_path = os.environ.get('CERT_PATH', '/etc/webhook/certs')
    key_file = os.path.join(cert_path, 'tls.key')
    cert_file = os.path.join(cert_path, 'tls.crt')
    
    if os.path.exists(key_file) and os.path.exists(cert_file):
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain(cert_file, key_file)
        app.run(host='0.0.0.0', port=8443, ssl_context=context)
    else:
        logger.warning("TLS certificates not found, running in insecure mode (for development only)")
        app.run(host='0.0.0.0', port=8080)