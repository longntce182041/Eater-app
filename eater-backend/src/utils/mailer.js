const nodemailer = require("nodemailer");
const { mailConfig } = require("../config/mail");
const { AppError } = require("./errors");

let transporter;

function getTransporter() {
    if (transporter) return transporter;

    if (!mailConfig.host || !mailConfig.user || !mailConfig.pass) {
        throw new AppError("SMTP is not configured", 500);
    }

    transporter = nodemailer.createTransport({
        host: mailConfig.host,
        port: mailConfig.port,
        secure: mailConfig.secure,
        auth: {
            user: mailConfig.user,
            pass: mailConfig.pass,
        },
    });

    return transporter;
}

async function sendPasswordResetEmail({ to, otp }) {
    const mail = {
        from: mailConfig.from,
        to,
        subject: "Your 6-digit OTP to reset password",
        text: `You requested a password reset.

Your 6-digit OTP code is:
${otp}

This code will expire in 15 minutes.

Enter this code in the Eater app to reset your password.

If you did not request this, please ignore.`,
        html: `<p>You requested a password reset.</p>
<p style="font-size: 18px; font-weight: bold; margin: 20px 0;">Your 6-digit OTP:</p>
<p style="font-size: 32px; letter-spacing: 8px; font-weight: bold; font-family: monospace; background-color: #f0f0f0; padding: 15px; border-radius: 8px; text-align: center;">${otp}</p>
<p style="color: #666; margin-top: 20px;">This code will expire in 15 minutes.</p>
<p>Enter this code in the Eater app to reset your password.</p>
<p style="color: #999; font-size: 12px; margin-top: 30px;">If you did not request this, please ignore.</p>`,
    };

    const transport = getTransporter();
    await transport.sendMail(mail);
}

module.exports = {
    sendPasswordResetEmail,
};
