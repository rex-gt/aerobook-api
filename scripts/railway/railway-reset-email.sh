#!/bin/bash

# Railway Email Configuration Reset
# Removes SMTP environment variables from Railway

echo "=========================================="
echo "WingTime - Railway Email Reset"
echo "=========================================="
echo ""

# Check Railway status
if ! railway status &> /dev/null; then
    echo "❌ Not linked to a Railway project."
    exit 1
fi

echo "⚠️  WARNING: This will delete all SMTP-related environment variables"
echo ""

railway variables | grep -E "SMTP_|APP_URL"
echo ""

read -p "Are you sure you want to delete these variables? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Reset cancelled."
    exit 0
fi

echo ""
echo "Removing SMTP variables..."
echo ""

# Delete variables
railway variables delete SMTP_HOST --yes 2>/dev/null && echo "✓ Deleted SMTP_HOST"
railway variables delete SMTP_PORT --yes 2>/dev/null && echo "✓ Deleted SMTP_PORT"
railway variables delete SMTP_SECURE --yes 2>/dev/null && echo "✓ Deleted SMTP_SECURE"
railway variables delete SMTP_USER --yes 2>/dev/null && echo "✓ Deleted SMTP_USER"
railway variables delete SMTP_PASS --yes 2>/dev/null && echo "✓ Deleted SMTP_PASS"
railway variables delete SMTP_FROM --yes 2>/dev/null && echo "✓ Deleted SMTP_FROM"
railway variables delete APP_URL --yes 2>/dev/null && echo "✓ Deleted APP_URL"

echo ""
echo "✓ SMTP configuration removed"
echo ""
echo "Run ./railway-setup-email.sh to reconfigure"
echo ""
