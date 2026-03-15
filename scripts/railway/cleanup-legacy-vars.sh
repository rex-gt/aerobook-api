#!/bin/bash

# Railway Legacy Variables Cleanup
# Removes old/unused environment variables

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

echo "Scanning for legacy variables..."
echo ""

# Define legacy variable patterns
legacy_found=false

# Check for SMTP variables (replaced by Resend)
smtp_vars=$(railway variables | grep -E "SMTP_" | awk -F'│' '{print $1}' | xargs)
if [ -n "$smtp_vars" ]; then
    echo "📧 Legacy SMTP variables found (replaced by Resend):"
    railway variables | grep -E "SMTP_"
    echo ""
    legacy_found=true
fi

# Check for old DB_ variables (Railway uses DATABASE_URL)
db_vars=$(railway variables | grep -E "^║ DB_" | awk -F'│' '{print $1}' | xargs)
if [ -n "$db_vars" ]; then
    echo "🗄️  Legacy DB_ variables found (Railway provides DATABASE_URL):"
    railway variables | grep -E "^║ DB_"
    echo ""
    legacy_found=true
fi

if [ "$legacy_found" = false ]; then
    echo "✓ No legacy variables found. Environment is clean!"
    echo ""
    exit 0
fi

echo "=========================================="
read -p "Delete all legacy variables? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "Removing legacy variables..."
echo ""

# Remove SMTP variables
yes | railway variable delete SMTP_HOST 2>/dev/null && echo "✓ Deleted SMTP_HOST"
yes | railway variable delete SMTP_PORT 2>/dev/null && echo "✓ Deleted SMTP_PORT"
yes | railway variable delete SMTP_SECURE 2>/dev/null && echo "✓ Deleted SMTP_SECURE"
yes | railway variable delete SMTP_USER 2>/dev/null && echo "✓ Deleted SMTP_USER"
yes | railway variable delete SMTP_PASS 2>/dev/null && echo "✓ Deleted SMTP_PASS"
yes | railway variable delete SMTP_FROM 2>/dev/null && echo "✓ Deleted SMTP_FROM"

# Remove old DB_ variables
yes | railway variable delete DB_HOST 2>/dev/null && echo "✓ Deleted DB_HOST"
yes | railway variable delete DB_PORT 2>/dev/null && echo "✓ Deleted DB_PORT"
yes | railway variable delete DB_USER 2>/dev/null && echo "✓ Deleted DB_USER"
yes | railway variable delete DB_PASSWORD 2>/dev/null && echo "✓ Deleted DB_PASSWORD"
yes | railway variable delete DB_NAME 2>/dev/null && echo "✓ Deleted DB_NAME"

echo ""
echo "✓ Legacy cleanup complete!"
echo ""
echo "Current environment variables:"
./scripts/railway/view-vars.sh 2>/dev/null || railway variables
echo ""
