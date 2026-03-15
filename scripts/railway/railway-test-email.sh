#!/bin/bash

# Railway Email Test Script
# Tests email configuration by triggering a test email

echo "=========================================="
echo "WingTime - Railway Email Test"
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

# Get the deployment URL
echo "Getting your Railway deployment URL..."
echo ""

# Try to get the URL from railway
deployment_url=$(railway status 2>/dev/null | grep -o 'https://[^ ]*' | head -1)

if [ -z "$deployment_url" ]; then
    read -p "Enter your Railway deployment URL (e.g., https://wingtime-api.railway.app): " deployment_url
fi

echo "Using URL: $deployment_url"
echo ""

# Get test email address
read -p "Enter email address to send test email to: " test_email
echo ""

echo "Sending test email..."
echo ""

# Test endpoint (you'll need to create this in your API)
response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "$deployment_url/api/test-email" \
  -H "Content-Type: application/json" \
  -d "{\"to\":\"$test_email\"}")

http_status=$(echo "$response" | grep "HTTP_STATUS" | cut -d':' -f2)
body=$(echo "$response" | grep -v "HTTP_STATUS")

if [ "$http_status" = "200" ]; then
    echo "✓ Test email sent successfully!"
    echo ""
    echo "Response: $body"
    echo ""
    echo "Check $test_email inbox (and spam folder)"
else
    echo "❌ Failed to send test email"
    echo ""
    echo "HTTP Status: $http_status"
    echo "Response: $body"
    echo ""
    echo "Check Railway logs with: railway logs"
fi

echo ""
