#!/bin/bash

# Railway Variables Viewer
# Quick script to view all environment variables on Railway

echo "=========================================="
echo "Railway Environment Variables"
echo "=========================================="
echo ""

# Check if railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI is not installed."
    exit 1
fi

# Check if logged in and linked
if ! railway status &> /dev/null; then
    echo "❌ Not linked to a Railway project."
    echo "Run: railway link"
    exit 1
fi

echo "Project:"
railway status
echo ""

echo "=========================================="
echo "All Variables"
echo "=========================================="
railway variables
echo ""

echo "=========================================="
echo "Email Configuration (Resend)"
echo "=========================================="
railway variables | grep -E "RESEND_|APP_URL" || echo "No Resend variables found"
echo ""

echo "=========================================="
echo "JWT/Auth Configuration"
echo "=========================================="
railway variables | grep -E "JWT_|RESET_TOKEN" || echo "No JWT variables found"
echo ""

echo "=========================================="
echo "Database Configuration"
echo "=========================================="
railway variables | grep -E "DATABASE_|DB_|POSTGRES" || echo "No database variables found"
echo ""

echo "=========================================="
echo "Node/App Configuration"
echo "=========================================="
railway variables | grep -E "NODE_ENV|PORT" || echo "No Node variables found"
echo ""
