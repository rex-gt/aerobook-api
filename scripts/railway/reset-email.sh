#!/bin/bash

# Railway Email Configuration Reset
# Removes Resend environment variables from Railway

echo "=========================================="
echo "WingTime - Railway Email Reset"
echo "=========================================="
echo ""

# Check Railway status
if ! railway status &> /dev/null; then
    echo "❌ Not linked to a Railway project."
    exit 1
fi

echo "⚠️  WARNING: This will delete all email-related environment variables"
echo ""

railway variables | grep -E "RESEND_|APP_URL"
echo ""

read -p "Are you sure you want to delete these variables? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Reset cancelled."
    exit 0
fi

echo ""
echo "Removing Resend variables..."
echo ""

# Delete variables
railway variables delete RESEND_API_KEY --yes 2>/dev/null && echo "✓ Deleted RESEND_API_KEY"
railway variables delete RESEND_FROM --yes 2>/dev/null && echo "✓ Deleted RESEND_FROM"
railway variables delete APP_URL --yes 2>/dev/null && echo "✓ Deleted APP_URL"

# Also clean up old SMTP variables if they exist
railway variables delete SMTP_HOST --yes 2>/dev/null && echo "✓ Deleted SMTP_HOST (legacy)"
railway variables delete SMTP_PORT --yes 2>/dev/null && echo "✓ Deleted SMTP_PORT (legacy)"
railway variables delete SMTP_SECURE --yes 2>/dev/null && echo "✓ Deleted SMTP_SECURE (legacy)"
railway variables delete SMTP_USER --yes 2>/dev/null && echo "✓ Deleted SMTP_USER (legacy)"
railway variables delete SMTP_PASS --yes 2>/dev/null && echo "✓ Deleted SMTP_PASS (legacy)"
railway variables delete SMTP_FROM --yes 2>/dev/null && echo "✓ Deleted SMTP_FROM (legacy)"

echo ""
echo "✓ Email configuration removed"
echo ""
echo "Run ./scripts/railway/setup-email.sh to reconfigure"
echo ""
