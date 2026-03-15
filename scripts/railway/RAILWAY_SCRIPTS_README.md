# Railway CLI Scripts for WingTime

Batch scripts to manage Railway environment variables and deployments from your local CLI.

## Prerequisites

1. **Install Railway CLI:**
   ```bash
   brew install railway
   ```

2. **Login to Railway:**
   ```bash
   railway login
   ```

3. **Link to your project:**
   ```bash
   cd wingtime-api
   railway link
   ```

## Available Scripts

### 1. `railway-setup-email.sh` - Configure Email (Gmail)

Sets up SMTP environment variables for sending emails via Gmail.

**What you need:**
- Your Gmail address
- Gmail App Password (16 characters)
  - Go to https://myaccount.google.com/security
  - Enable 2-Factor Authentication
  - Create App Password for "Mail"

**Usage:**
```bash
chmod +x railway-setup-email.sh
./railway-setup-email.sh
```

**Variables it sets:**
- `SMTP_HOST` - smtp.gmail.com
- `SMTP_PORT` - 587
- `SMTP_SECURE` - false
- `SMTP_USER` - Your Gmail address
- `SMTP_PASS` - Your App Password
- `SMTP_FROM` - From address for emails
- `APP_URL` - Your frontend URL
- `JWT_SECRET` - (optional) For token generation
- `RESET_TOKEN_SECRET` - (optional) For password reset tokens

### 2. `railway-view-vars.sh` - View All Variables

Displays all environment variables currently set on Railway, organized by category.

**Usage:**
```bash
chmod +x railway-view-vars.sh
./railway-view-vars.sh
```

**Shows:**
- All variables
- SMTP configuration
- JWT/Auth configuration
- Database configuration
- Node/App configuration

### 3. `railway-test-email.sh` - Test Email Sending

Tests your email configuration by sending a test email.

**Usage:**
```bash
chmod +x railway-test-email.sh
./railway-test-email.sh
```

**Note:** Requires a test endpoint in your API (see below).

### 4. `railway-reset-email.sh` - Remove Email Configuration

Removes all SMTP-related environment variables from Railway.

**Usage:**
```bash
chmod +x railway-reset-email.sh
./railway-reset-email.sh
```

**Use this when:**
- Switching email providers
- Removing email functionality
- Resetting configuration to start fresh

## Quick Start Guide

### Initial Email Setup

```bash
# 1. Make scripts executable
chmod +x railway-*.sh

# 2. Set up email configuration
./railway-setup-email.sh

# 3. Verify variables were set
./railway-view-vars.sh

# 4. Check Railway logs
railway logs

# 5. Test email (once test endpoint is added)
./railway-test-email.sh
```

## Gmail App Password Setup

Since you're using Gmail, you need an App Password:

1. Go to https://myaccount.google.com/security
2. Click on "2-Step Verification" (enable it if not already)
3. Scroll down and click "App passwords"
4. Select "Mail" and your device
5. Click "Generate"
6. Copy the 16-character password (no spaces)
7. Use this password in the setup script

**Important:** Do NOT use your regular Gmail password!

## Add Test Email Endpoint to Your API

Add this to your `server.js`:

```javascript
// Test email endpoint
app.post('/api/test-email', asyncHandler(async (req, res) => {
  const { to } = req.body;
  const { sendWelcomeEmail } = require('./emailService');
  
  try {
    // Create a test user object
    const testUser = {
      id: 999,
      first_name: 'Test',
      email: to || process.env.SMTP_USER
    };
    
    await sendWelcomeEmail(testUser);
    
    res.json({ 
      message: 'Test email sent successfully',
      to: testUser.email 
    });
  } catch (error) {
    console.error('Email test failed:', error);
    res.status(500).json({ 
      error: 'Failed to send email',
      message: error.message 
    });
  }
}));
```

Then commit and push:
```bash
git add server.js
git commit -m "Add test email endpoint"
git push
```

## Troubleshooting

### "Railway CLI not found"
```bash
brew install railway
```

### "Not logged in"
```bash
railway login
```

### "Not linked to project"
```bash
cd wingtime-api
railway link
```

### Check if variables are set
```bash
railway variables
# or
./railway-view-vars.sh
```

### View deployment logs
```bash
railway logs
# or for live logs
railway logs --follow
```

### Test SMTP connection
```bash
# Connect to Railway shell
railway shell

# Test with Node
node -e "console.log('SMTP_HOST:', process.env.SMTP_HOST)"
```

### Email not sending

1. **Check logs:**
   ```bash
   railway logs | grep -i email
   ```

2. **Verify variables:**
   ```bash
   ./railway-view-vars.sh
   ```

3. **Test Gmail App Password locally:**
   ```bash
   cd wingtime-api
   railway run node
   > require('./emailService').sendWelcomeEmail({id:1, first_name:'Test', email:'your@email.com'})
   ```

4. **Common issues:**
   - Wrong App Password → Regenerate it
   - 2FA not enabled → Enable in Gmail settings
   - Blocked by Gmail → Check Gmail security alerts
   - Wrong SMTP settings → Should be smtp.gmail.com:587

## Other Useful Railway Commands

```bash
# View current project
railway status

# View all variables
railway variables

# Set a single variable
railway variables set KEY=value

# Delete a variable
railway variables delete KEY

# View logs
railway logs

# Live log stream
railway logs --follow

# Open Railway dashboard
railway open

# Deploy immediately
railway up

# Enter Railway shell (with all env vars)
railway shell

# Run a command with Railway env vars
railway run npm test
```

## Production Email Providers

For production, consider these alternatives to Gmail:

### SendGrid (Free: 100 emails/day)
```bash
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASS=your-sendgrid-api-key
```

### Resend (Free: 3,000 emails/month)
```bash
# Requires code changes to use Resend SDK
npm install resend
```

### Postmark (Free: 100 emails/month)
```bash
SMTP_HOST=smtp.postmarkapp.com
SMTP_PORT=587
SMTP_USER=your-server-token
SMTP_PASS=your-server-token
```

## Security Best Practices

1. **Never commit secrets to Git:**
   - `.env` should be in `.gitignore`
   - Use `.env.example` for templates

2. **Use different credentials for dev/prod:**
   - Local: Test Gmail account
   - Railway: Production email service

3. **Rotate App Passwords regularly:**
   - Generate new App Password
   - Update Railway: `railway variables set SMTP_PASS=new-password`

4. **Monitor email sending:**
   - Check Railway logs regularly
   - Set up alerts for errors

## Files Structure

```
wingtime-api/
├── railway-setup-email.sh    # Setup SMTP configuration
├── railway-view-vars.sh      # View all variables
├── railway-test-email.sh     # Test email sending
├── railway-reset-email.sh    # Remove email config
├── RAILWAY_SCRIPTS_README.md # This file
├── emailService.js           # Your email service
├── server.js                 # Express server
└── .env.example              # Template for local env vars
```

## Support

- Railway Docs: https://docs.railway.app/
- Railway CLI: https://docs.railway.app/develop/cli
- Gmail App Passwords: https://support.google.com/accounts/answer/185833

## License

MIT
