#!/bin/bash

# Fix for Git Bash on Windows
export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL="*"

# Tell gcloud exactly where Python is
export CLOUDSDK_PYTHON="C:/Users/DELL/AppData/Local/Programs/Python/Python313/python.exe"

# Full path to gcloud
GCLOUD="/c/Users/DELL/google-cloud-sdk/bin/gcloud.cmd"

# ─────────────────────────────────────────
# Now replace every gcloud command in the
# script with $GCLOUD instead of gcloud
# ─────────────────────────────────────────

echo "========================================="
echo "SMYKKER SERVER - LOAD BALANCER AUDIT"
echo "========================================="

echo ""
echo "1. STATIC IP ADDRESS"
echo "─────────────────────"
$GCLOUD compute addresses list --global

echo ""
echo "2. HEALTH CHECK"
echo "─────────────────────"
$GCLOUD compute health-checks list

echo ""
echo "3. BACKEND SERVICE"
echo "─────────────────────"
$GCLOUD compute backend-services list --global

echo ""
echo "4. INSTANCE GROUP"
echo "─────────────────────"
$GCLOUD compute instance-groups list

echo ""
echo "5. URL MAP"
echo "─────────────────────"
$GCLOUD compute url-maps list

echo ""
echo "6. SSL CERTIFICATE"
echo "─────────────────────"
$GCLOUD compute ssl-certificates list

echo ""
echo "7. HTTPS PROXY"
echo "─────────────────────"
$GCLOUD compute target-https-proxies list

echo ""
echo "8. FORWARDING RULE"
echo "─────────────────────"
$GCLOUD compute forwarding-rules list --global

echo ""
echo "9. WAF SECURITY POLICY"
echo "─────────────────────"
$GCLOUD compute security-policies list

echo ""
echo "10. FIREWALL RULES"
echo "─────────────────────"
$GCLOUD compute firewall-rules list \
  --filter="network=security-vpc" \
  --format="table(name,allowed,sourceRanges,targetTags)"

echo ""
echo "========================================="
echo "CHAIN VERIFICATION"
echo "========================================="

echo -n "Static IP:        "
$GCLOUD compute addresses describe smykker-lb-ip \
  --global --format="get(address)" 2>/dev/null \
  && echo " ✅" || echo " ❌ MISSING"

echo -n "Forwarding Rule:  "
$GCLOUD compute forwarding-rules describe smykker-forwarding-rule \
  --global --format="get(name)" 2>/dev/null \
  && echo " ✅" || echo " ❌ MISSING"

echo -n "HTTPS Proxy:      "
$GCLOUD compute target-https-proxies describe smykker-https-proxy \
  --global --format="get(name)" 2>/dev/null \
  && echo " ✅" || echo " ❌ MISSING"

echo -n "URL Map:          "
$GCLOUD compute url-maps describe smykker-url-map \
  --format="get(name)" 2>/dev/null \
  && echo " ✅" || echo " ❌ MISSING"

echo -n "Backend Service:  "
$GCLOUD compute backend-services describe smykker-backend \
  --global --format="get(name)" 2>/dev/null \
  && echo " ✅" || echo " ❌ MISSING"

echo -n "Health Check:     "
$GCLOUD compute health-checks describe smykker-health-check \
  --format="get(name)" 2>/dev/null \
  && echo " ✅" || echo " ❌ MISSING"

echo -n "SSL Certificate:  "
$GCLOUD compute ssl-certificates describe smykker-ssl-cert \
  --global --format="get(name)" 2>/dev/null \
  && echo " ✅" || echo " ❌ MISSING"

echo -n "WAF Policy:       "
$GCLOUD compute security-policies describe smykker-waf \
  --format="get(name)" 2>/dev/null \
  && echo " ✅" || echo " ❌ MISSING"

echo -n "Instance Group:   "
$GCLOUD compute instance-groups unmanaged describe smykker-group \
  --zone=us-central1-a --format="get(name)" 2>/dev/null \
  && echo " ✅" || echo " ❌ MISSING"

echo -n "VM Running:       "
$GCLOUD compute instances describe smykker-server \
  --zone=us-central1-a --format="get(status)" 2>/dev/null \
  && echo " ✅" || echo " ❌ MISSING"

echo ""
echo "========================================="
echo "AUDIT COMPLETE"
echo "========================================="