# app.py
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/health")
def health():
    # Simple readiness check
    return jsonify(status="ok"), 200

if __name__ == "__main__":
    # Ensure it binds on 0.0.0.0:5000 so GitHub’s runner can reach it
    app.run(host="0.0.0.0", port=5000)
