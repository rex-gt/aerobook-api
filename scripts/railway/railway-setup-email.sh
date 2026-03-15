#!/bin/bash

# Railway Email Configuration Setup Script
# This script sets up SMTP environment variables for Gmail on Railway

echo "=========================================="
echo "WingTime - Railway Email Setup (Gmail)"
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

# Prompt for SMTP configuration
echo "=========================================="
echo "Gmail SMTP Configuration"
echo "=========================================="
echo ""
echo "You'll need:"
echo "1. Your Gmail address"
echo "2. A Gmail App Password (NOT your regular password)"
echo ""
echo "To create an App Password:"
echo "1. Go to https://myaccount.google.com/security"
echo "2. Enable 2-Factor Authentication (required)"
echo "3. Search for 'App Passwords'"
echo "4. Generate password for 'Mail'"
echo "5. Copy the 16-character password"
echo ""
read -p "Press Enter when ready to continue..."
echo ""

# Get SMTP configuration
read -p "Enter your Gmail address: " gmail_address
echo ""

read -p "Enter your Gmail App Password (16 characters, no spaces): " -s gmail_app_password
echo ""
echo ""

read -p "Enter the 'From' email address [default: noreply@wingtime.app]: " smtp_from
smtp_from=${smtp_from:-noreply@wingtime.app}
echo ""

read -p "Enter your app URL [default: https://wingtime.vercel.app]: " app_url
app_url=${app_url:-https://wingtime.vercel.app}
echo ""

# Confirm settings
echo "=========================================="
echo "Configuration Summary"
echo "=========================================="
echo "SMTP_HOST: smtp.gmail.com"
echo "SMTP_PORT: 587"
echo "SMTP_SECURE: false"
echo "SMTP_USER: $gmail_address"
echo "SMTP_PASS: [hidden]"
echo "SMTP_FROM: $smtp_from"
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

railway variables set SMTP_HOST=smtp.gmail.com
railway variables set SMTP_PORT=587
railway variables set SMTP_SECURE=false
railway variables set SMTP_USER="$gmail_address"
railway variables set SMTP_PASS="$gmail_app_password"
railway variables set SMTP_FROM="$smtp_from"
railway variables set APP_URL="$app_url"

echo ""
echo "✓ Environment variables set successfully!"
echo ""

# Verify variables
echo "=========================================="
echo "Verifying Variables"
echo "=========================================="
echo ""
railway variables | grep -E "(SMTP_|APP_URL)"
echo ""

# Ask about JWT secret
echo "=========================================="
echo "JWT Secret Configuration"
echo "=========================================="
echo ""
echo "Your emailService.js uses JWT_SECRET or RESET_TOKEN_SECRET."
echo ""

# Check if JWT_SECRET exists
if railway variables | grep -q "JWT_SECRET"; then
    echo "✓ JWT_SECRET already exists in Railway"
else
    echo "⚠️  JWT_SECRET not found"
    read -p "Would you like to set JWT_SECRET now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Generate a random secret
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
        # Generate a random secret
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
echo "3. Test email sending from your app"
echo ""
echo "To view all variables:"
echo "  railway variables"
echo ""
echo "To update a variable:"
echo "  railway variables set VARIABLE_NAME=value"
echo ""
