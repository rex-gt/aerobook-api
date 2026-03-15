#!/bin/bash

# Railway Legacy Variables Cleanup
# Removes old SMTP environment variables that are no longer needed

echo "=========================================="
echo "AeroBook - Cleanup Legacy Variables"
echo "=========================================="
echo ""

# Check Railway status
if ! railway status &> /dev/null; then
    echo "❌ Not linked to a Railway project."
    exit 1
fi

echo "Current project:"
railway status
echo ""

echo "Checking for legacy SMTP variables..."
echo ""

# Check which legacy variables exist
legacy_vars=""
railway variables | grep -q "SMTP_HOST" && legacy_vars="$legacy_vars SMTP_HOST"
railway variables | grep -q "SMTP_PORT" && legacy_vars="$legacy_vars SMTP_PORT"
railway variables | grep -q "SMTP_SECURE" && legacy_vars="$legacy_vars SMTP_SECURE"
railway variables | grep -q "SMTP_USER" && legacy_vars="$legacy_vars SMTP_USER"
railway variables | grep -q "SMTP_PASS" && legacy_vars="$legacy_vars SMTP_PASS"
railway variables | grep -q "SMTP_FROM" && legacy_vars="$legacy_vars SMTP_FROM"

if [ -z "$legacy_vars" ]; then
    echo "✓ No legacy SMTP variables found. Nothing to clean up."
    echo ""
    exit 0
fi

echo "Found legacy variables:"
railway variables | grep -E "SMTP_"
echo ""

read -p "Delete these legacy SMTP variables? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "Removing legacy SMTP variables..."
echo ""

# Delete legacy variables
railway variables delete SMTP_HOST --yes 2>/dev/null && echo "✓ Deleted SMTP_HOST"
railway variables delete SMTP_PORT --yes 2>/dev/null && echo "✓ Deleted SMTP_PORT"
railway variables delete SMTP_SECURE --yes 2>/dev/null && echo "✓ Deleted SMTP_SECURE"
railway variables delete SMTP_USER --yes 2>/dev/null && echo "✓ Deleted SMTP_USER"
railway variables delete SMTP_PASS --yes 2>/dev/null && echo "✓ Deleted SMTP_PASS"
railway variables delete SMTP_FROM --yes 2>/dev/null && echo "✓ Deleted SMTP_FROM"

echo ""
echo "✓ Legacy cleanup complete!"
echo ""
echo "Current email configuration (Resend):"
railway variables | grep -E "RESEND_" || echo "No Resend variables found"
echo ""
