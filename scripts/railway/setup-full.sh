#!/bin/bash

# Railway Complete Environment Setup Script
# Sets up all environment variables for AeroBook API

echo "=========================================="
echo "AeroBook - Complete Environment Setup"
echo "=========================================="
echo ""

# Check if railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI is not installed."
    echo ""
    echo "Install it with: brew install railway"
    echo "Or visit: https://docs.railway.app/develop/cli"
    exit 1
fi

# Check if logged in
if ! railway whoami &> /dev/null; then
    echo "❌ Not logged into Railway."
    echo ""
    echo "Please run: railway login"
    exit 1
fi

echo "✓ Railway CLI is ready"
echo ""

# Check if linked to a project
if ! railway status &> /dev/null; then
    echo "⚠️  Not linked to a Railway project."
    echo ""
    read -p "Would you like to link to a project now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        railway link
    else
        echo "Please run 'railway link' first, then run this script again."
        exit 1
    fi
fi

echo "Current Railway project:"
railway status
echo ""

# ==========================================
# Frontend / App Configuration
# ==========================================
echo "=========================================="
echo "1. Frontend / App Configuration"
echo "=========================================="
echo ""

read -p "Enter your frontend URL [default: https://aerobook.app]: " app_url
app_url=${app_url:-https://aerobook.app}

read -p "Enter allowed origins (comma-separated) [default: $app_url]: " allowed_origins
allowed_origins=${allowed_origins:-$app_url}

echo ""

# ==========================================
# JWT / Security Configuration
# ==========================================
echo "=========================================="
echo "2. JWT / Security Configuration"
echo "=========================================="
echo ""

echo "Generating secure secrets..."
jwt_secret=$(openssl rand -base64 32)
reset_token_secret=$(openssl rand -base64 32)

echo "✓ JWT_SECRET generated"
echo "✓ RESET_TOKEN_SECRET generated"
echo ""

# ==========================================
# Email Configuration (Resend)
# ==========================================
echo "=========================================="
echo "3. Email Configuration (Resend)"
echo "=========================================="
echo ""
echo "Get your API key from: https://resend.com/api-keys"
echo ""

read -p "Enter your Resend API key (starts with re_): " resend_api_key
echo ""

read -p "Enter the 'From' address [default: AeroBook <noreply@aerobook.app>]: " resend_from
resend_from=${resend_from:-"AeroBook <noreply@aerobook.app>"}
echo ""

# ==========================================
# Confirm Settings
# ==========================================
echo "=========================================="
echo "Configuration Summary"
echo "=========================================="
echo ""
echo "Frontend:"
echo "  APP_URL: $app_url"
echo "  ALLOWED_ORIGINS: $allowed_origins"
echo ""
echo "Security:"
echo "  JWT_SECRET: [generated]"
echo "  RESET_TOKEN_SECRET: [generated]"
echo ""
echo "Email (Resend):"
echo "  RESEND_API_KEY: ${resend_api_key:0:10}..."
echo "  RESEND_FROM: $resend_from"
echo ""

read -p "Is this correct? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

# ==========================================
# Set Railway Variables
# ==========================================
echo ""
echo "Setting Railway environment variables..."
echo ""

# Frontend / App
railway variables set APP_URL="$app_url"
railway variables set ALLOWED_ORIGINS="$allowed_origins"

# Security
railway variables set JWT_SECRET="$jwt_secret"
railway variables set RESET_TOKEN_SECRET="$reset_token_secret"

# Email
railway variables set RESEND_API_KEY="$resend_api_key"
railway variables set RESEND_FROM="$resend_from"

echo ""
echo "✓ All environment variables set successfully!"
echo ""

# ==========================================
# Clean Up Legacy Variables
# ==========================================
echo "=========================================="
echo "Cleaning Up Legacy Variables"
echo "=========================================="
echo ""

# Remove old SMTP variables
railway variables delete SMTP_HOST --yes 2>/dev/null && echo "✓ Removed SMTP_HOST"
railway variables delete SMTP_PORT --yes 2>/dev/null && echo "✓ Removed SMTP_PORT"
railway variables delete SMTP_SECURE --yes 2>/dev/null && echo "✓ Removed SMTP_SECURE"
railway variables delete SMTP_USER --yes 2>/dev/null && echo "✓ Removed SMTP_USER"
railway variables delete SMTP_PASS --yes 2>/dev/null && echo "✓ Removed SMTP_PASS"
railway variables delete SMTP_FROM --yes 2>/dev/null && echo "✓ Removed SMTP_FROM"

# Remove old DB_ variables (Railway uses DATABASE_URL)
railway variables delete DB_HOST --yes 2>/dev/null && echo "✓ Removed DB_HOST"
railway variables delete DB_PORT --yes 2>/dev/null && echo "✓ Removed DB_PORT"
railway variables delete DB_USER --yes 2>/dev/null && echo "✓ Removed DB_USER"
railway variables delete DB_PASSWORD --yes 2>/dev/null && echo "✓ Removed DB_PASSWORD"
railway variables delete DB_NAME --yes 2>/dev/null && echo "✓ Removed DB_NAME"

echo ""

# ==========================================
# Verify Configuration
# ==========================================
echo "=========================================="
echo "Final Configuration"
echo "=========================================="
echo ""
railway variables | grep -E "APP_URL|ALLOWED_ORIGINS|JWT_SECRET|RESET_TOKEN|RESEND_"
echo ""

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Railway will automatically redeploy"
echo "2. Test your deployment: railway logs"
echo "3. Test email: ./scripts/railway/test-email.sh"
echo ""
echo "Note: DATABASE_URL is automatically provided by Railway"
echo "when you have a PostgreSQL database attached."
echo ""
