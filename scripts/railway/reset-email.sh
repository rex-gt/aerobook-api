#!/bin/bash

# Railway Email Configuration Reset
# Removes Resend environment variables from Railway

echo "=========================================="
echo "AeroBook - Railway Email Reset"
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
yes | railway variable delete RESEND_API_KEY 2>/dev/null && echo "✓ Deleted RESEND_API_KEY"
yes | railway variable delete RESEND_FROM 2>/dev/null && echo "✓ Deleted RESEND_FROM"
yes | railway variable delete APP_URL 2>/dev/null && echo "✓ Deleted APP_URL"

# Also clean up old SMTP variables if they exist
yes | railway variable delete SMTP_HOST 2>/dev/null && echo "✓ Deleted SMTP_HOST (legacy)"
yes | railway variable delete SMTP_PORT 2>/dev/null && echo "✓ Deleted SMTP_PORT (legacy)"
yes | railway variable delete SMTP_SECURE 2>/dev/null && echo "✓ Deleted SMTP_SECURE (legacy)"
yes | railway variable delete SMTP_USER 2>/dev/null && echo "✓ Deleted SMTP_USER (legacy)"
yes | railway variable delete SMTP_PASS 2>/dev/null && echo "✓ Deleted SMTP_PASS (legacy)"
yes | railway variable delete SMTP_FROM 2>/dev/null && echo "✓ Deleted SMTP_FROM (legacy)"

echo ""
echo "✓ Email configuration removed"
echo ""
echo "Run ./scripts/railway/setup-email.sh to reconfigure"
echo ""
