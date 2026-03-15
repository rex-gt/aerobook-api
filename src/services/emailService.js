const nodemailer = require('nodemailer');
const jwt = require('jsonwebtoken');
const dns = require('dns');
const net = require('net');

// Custom lookup function that forces IPv4
const lookup4 = (hostname, options, callback) => {
    if (typeof options === 'function') {
        callback = options;
        options = {};
    }
    dns.resolve4(hostname, (err, addresses) => {
        if (err) {
            callback(err, null, null);
        } else if (addresses && addresses.length > 0) {
            callback(null, addresses[0], 4);
        } else {
            callback(new Error(`No IPv4 address found for ${hostname}`), null, null);
        }
    });
};

const createTransporter = () => {
    const smtpPort = parseInt(process.env.SMTP_PORT, 10) || 587;
    return nodemailer.createTransport({
        host: process.env.SMTP_HOST,
        port: smtpPort,
        secure: process.env.SMTP_SECURE === 'true' || smtpPort === 465,
        auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASS,
        },
        // Force IPv4 connection
        tls: {
            lookup: lookup4,
        },
        // Pass lookup to socket as well
        socket: {
            lookup: lookup4,
        },
    });
};

const sendWelcomeEmail = async (user) => {
    const appUrl = process.env.APP_URL || 'https://localhost:5173';
    const resetSecret = process.env.RESET_TOKEN_SECRET || process.env.JWT_SECRET;
    const resetToken = jwt.sign(
        { id: user.id, purpose: 'password-reset' },
        resetSecret,
        { expiresIn: '24h' }
    );
    const resetLink = `${appUrl}/reset-password?token=${resetToken}`;

    const transporter = createTransporter();

    await transporter.sendMail({
        from: process.env.SMTP_FROM || 'noreply@wingtime.app',
        to: user.email,
        subject: 'Welcome to WingTime!',
        html: `
            <h1>Welcome to WingTime, ${user.first_name}!</h1>
            <p>Your account has been successfully created. You can now access the WingTime flight scheduling app.</p>
            <p>To set up your WingTime password, please click the link below:</p>
            <p><a href="${resetLink}">Set up your WingTime password</a></p>
            <p>This link will expire in 24 hours.</p>
            <p>If you did not create this account, please ignore this email.</p>
        `,
    });
};

module.exports = { sendWelcomeEmail };
