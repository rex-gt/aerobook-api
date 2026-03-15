#!/bin/bash

# Railway Email Test Script
# Tests email configuration using Railway shell

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

# Get test email address
read -p "Enter email address to send test email to: " test_email
echo ""

echo "Testing email configuration..."
echo ""

# Run inline Node.js code with Railway environment
railway run node -e "
const { sendWelcomeEmail } = require('./src/services/emailService');

const testUser = {
  id: 999,
  first_name: 'Test User',
  email: '${test_email}'
};

console.log('Sending test email to:', testUser.email);
console.log('SMTP Config:', {
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  user: process.env.SMTP_USER,
  from: process.env.SMTP_FROM
});

sendWelcomeEmail(testUser)
  .then(() => {
    console.log('✓ Test email sent successfully!');
    console.log('Check ${test_email} inbox (and spam folder)');
  })
  .catch((error) => {
    console.error('❌ Failed to send email:', error.message);
    console.error(error);
    process.exit(1);
  });
"

echo ""
echo "=========================================="
echo "If email didn't send, check logs:"
echo "  railway logs | grep -i email"
echo "=========================================="
echo ""
