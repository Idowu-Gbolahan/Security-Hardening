#!/bin/bash
# =============================================================
# fetch-secrets.sh
# Pulls TLS certificate and key from GCP Secret Manager
# into a RAM-only tmpfs location for container consumption.
# Runs automatically on every VM boot via systemd.
# =============================================================

set -euo pipefail

PROJECT="security-hardening-lab-498320"
SECRET_CERT="smykker-tls-cert"
SECRET_KEY="smykker-tls-key"
SECRETS_DIR="/run/secrets"

echo "[fetch-secrets] Starting secret retrieval..."

# Create the tmpfs mount if it doesn't already exist
if ! mountpoint -q "$SECRETS_DIR"; then
    mkdir -p "$SECRETS_DIR"
    mount -t tmpfs -o size=10m,mode=0700 tmpfs "$SECRETS_DIR"
    echo "[fetch-secrets] Mounted tmpfs at $SECRETS_DIR"
fi

# Fetch the TLS certificate
gcloud secrets versions access latest \
  --secret="$SECRET_CERT" \
  --project="$PROJECT" \
  > "$SECRETS_DIR/server.crt"

# Fetch the TLS private key
gcloud secrets versions access latest \
  --secret="$SECRET_KEY" \
  --project="$PROJECT" \
  > "$SECRETS_DIR/server.key"

# Lock down permissions
chmod 644 "$SECRETS_DIR/server.crt"
chmod 600 "$SECRETS_DIR/server.key"
chown root:root "$SECRETS_DIR/server.crt" "$SECRETS_DIR/server.key"

echo "[fetch-secrets] Secrets written successfully to $SECRETS_DIR ✅"