#!/bin/bash

# Railway Email Configuration Setup Script
# This script sets up Resend environment variables on Railway

echo "=========================================="
echo "AeroBook - Railway Email Setup (Resend)"
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

# Prompt for Resend configuration
echo "=========================================="
echo "Resend Configuration"
echo "=========================================="
echo ""
echo "You'll need:"
echo "1. A Resend API key (from https://resend.com/api-keys)"
echo "2. A verified 'From' address or domain"
echo ""
echo "For testing, you can use: onboarding@resend.dev"
echo "For production, verify your domain at https://resend.com/domains"
echo ""
read -p "Press Enter when ready to continue..."
echo ""

# Get Resend configuration
read -p "Enter your Resend API key (starts with re_): " resend_api_key
echo ""

read -p "Enter the 'From' address [default: AeroBook <noreply@aerobook.app>]: " resend_from
resend_from=${resend_from:-"AeroBook <noreply@aerobook.app>"}
echo ""

read -p "Enter your app URL [default: https://aerobook.app]: " app_url
app_url=${app_url:-https://aerobook.app}
echo ""

# Confirm settings
echo "=========================================="
echo "Configuration Summary"
echo "=========================================="
echo "RESEND_API_KEY: ${resend_api_key:0:10}..."
echo "RESEND_FROM: $resend_from"
echo "APP_URL: $app_url"
echo ""

read -p "Is this correct? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

# Set Railway variables
echo ""
echo "Setting Railway environment variables..."
echo ""

railway variables set RESEND_API_KEY="$resend_api_key"
railway variables set RESEND_FROM="$resend_from"
railway variables set APP_URL="$app_url"

echo ""
echo "✓ Environment variables set successfully!"
echo ""

# Verify variables
echo "=========================================="
echo "Verifying Variables"
echo "=========================================="
echo ""
railway variables | grep -E "(RESEND_|APP_URL)"
echo ""

# Ask about JWT secret
echo "=========================================="
echo "JWT Secret Configuration"
echo "=========================================="
echo ""

# Check if JWT_SECRET exists
if railway variables | grep -q "JWT_SECRET"; then
    echo "✓ JWT_SECRET already exists in Railway"
else
    echo "⚠️  JWT_SECRET not found"
    read -p "Would you like to set JWT_SECRET now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        jwt_secret=$(openssl rand -base64 32)
        railway variables set JWT_SECRET="$jwt_secret"
        echo "✓ JWT_SECRET set"
    fi
fi

# Check if RESET_TOKEN_SECRET exists
if railway variables | grep -q "RESET_TOKEN_SECRET"; then
    echo "✓ RESET_TOKEN_SECRET already exists in Railway"
else
    echo "⚠️  RESET_TOKEN_SECRET not found"
    read -p "Would you like to set RESET_TOKEN_SECRET now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        reset_secret=$(openssl rand -base64 32)
        railway variables set RESET_TOKEN_SECRET="$reset_secret"
        echo "✓ RESET_TOKEN_SECRET set"
    fi
fi

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Railway will automatically redeploy with new variables"
echo "2. Check deployment: railway logs"
echo "3. Test email: ./scripts/railway/test-email.sh"
echo ""
echo "To view all variables:"
echo "  railway variables"
echo ""
echo "To update a variable:"
echo "  railway variables set VARIABLE_NAME=value"
echo ""
