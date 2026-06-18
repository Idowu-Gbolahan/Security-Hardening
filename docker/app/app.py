"""
SmykkerPay - Backend Application
Flask REST API serving the SmykkerPay dashboard
"""

import os
import json
import hashlib
import secrets
from datetime import datetime
from functools import wraps
from flask import Flask, request, jsonify, session, render_template, redirect, url_for

app = Flask(__name__)

# Secret key for session management
# In production this would come from Secret Manager
app.secret_key = os.environ.get("APP_SECRET_KEY", secrets.token_hex(32))

# Security headers applied to every response
@app.after_request
def apply_security_headers(response):
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "SAMEORIGIN"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    response.headers["Cache-Control"] = "no-store"
    response.headers["Pragma"] = "no-cache"
    return response


# ─── Simulated user store ────────────────────────────────────────────────────
# In production this would be a real database (Cloud SQL, Firestore, etc.)
USERS = {
    "gbolahan": {
        "password_hash": hashlib.sha256("Smykker@2026".encode()).hexdigest(),
        "name": "Gbolahan Idowu",
        "role": "Security Engineer",
        "balance": "₦4,250,000.00"
    }
}

# ─── Simulated transaction data ──────────────────────────────────────────────
TRANSACTIONS = [
    {"id": "TXN001", "date": "2026-06-15", "description": "Cloud Infrastructure",   "amount": "-₦120,000", "status": "completed"},
    {"id": "TXN002", "date": "2026-06-14", "description": "Security Audit Fee",      "amount": "-₦85,000",  "status": "completed"},
    {"id": "TXN003", "date": "2026-06-13", "description": "Client Payment - ACME",   "amount": "+₦500,000", "status": "completed"},
    {"id": "TXN004", "date": "2026-06-12", "description": "GCP Subscription",        "amount": "-₦45,000",  "status": "pending"},
    {"id": "TXN005", "date": "2026-06-11", "description": "Consulting Revenue",      "amount": "+₦300,000", "status": "completed"},
]


# ─── Auth decorator ──────────────────────────────────────────────────────────
def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if "username" not in session:
            return redirect(url_for("login"))
        return f(*args, **kwargs)
    return decorated


# ─── Routes ──────────────────────────────────────────────────────────────────

@app.route("/")
def index():
    if "username" in session:
        return redirect(url_for("dashboard"))
    return redirect(url_for("login"))


@app.route("/login", methods=["GET", "POST"])
def login():
    error = None
    if request.method == "POST":
        username = request.form.get("username", "").strip().lower()
        password = request.form.get("password", "")
        password_hash = hashlib.sha256(password.encode()).hexdigest()

        user = USERS.get(username)
        if user and user["password_hash"] == password_hash:
            session.clear()
            session["username"] = username
            session["login_time"] = datetime.utcnow().isoformat()
            session.permanent = False
            return redirect(url_for("dashboard"))
        else:
            error = "Invalid credentials. Please try again."

    return render_template("login.html", error=error)


@app.route("/dashboard")
@login_required
def dashboard():
    username = session["username"]
    user = USERS[username]
    return render_template(
        "dashboard.html",
        user=user,
        transactions=TRANSACTIONS,
        login_time=session.get("login_time", "Unknown")
    )


@app.route("/logout", methods=["POST"])
@login_required
def logout():
    session.clear()
    return redirect(url_for("login"))


# ─── API Endpoints ───────────────────────────────────────────────────────────

@app.route("/api/status")
def api_status():
    return jsonify({
        "status": "operational",
        "service": "SmykkerPay API",
        "version": "1.0.0",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "environment": "production",
        "security": {
            "tls": True,
            "waf": True,
            "rate_limiting": True
        }
    })


@app.route("/api/transactions")
@login_required
def api_transactions():
    return jsonify({
        "username": session["username"],
        "count": len(TRANSACTIONS),
        "transactions": TRANSACTIONS
    })


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }), 200


# ─── Error Handlers ──────────────────────────────────────────────────────────

@app.errorhandler(404)
def not_found(e):
    return jsonify({"error": "Resource not found", "status": 404}), 404


@app.errorhandler(500)
def server_error(e):
    return jsonify({"error": "Internal server error", "status": 500}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)