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

async function sendConsultationRequestEmail({ to, userName, title }) {
    const mail = {
        from: mailConfig.from,
        to,
        subject: `New Consultation Request: ${title}`,
        text: `Hello,\n\nUser ${userName} has submitted a new nutrition consultation request.\n\nTitle: ${title}\n\nPlease log in to the Eater admin panel to review and respond.\n\nEater App`,
        html: `<p>Hello,</p>
<p>User <strong>${userName}</strong> has submitted a new nutrition consultation request.</p>
<p><strong>Title:</strong> ${title}</p>
<p>Please log in to the Eater admin panel to review and respond.</p>
<p style="color:#999;font-size:12px;margin-top:30px;">Eater App</p>`,
    };
    const transport = getTransporter();
    await transport.sendMail(mail);
}

async function sendConsultationReplyEmail({ to, nutritionistName, title }) {
    const mail = {
        from: mailConfig.from,
        to,
        subject: `Your consultation has been answered: ${title}`,
        text: `Hello,\n\nNutritionist ${nutritionistName} has replied to your consultation request.\n\nTitle: ${title}\n\nOpen the Eater app to read the full response.\n\nEater App`,
        html: `<p>Hello,</p>
<p>Nutritionist <strong>${nutritionistName}</strong> has replied to your consultation request.</p>
<p><strong>Title:</strong> ${title}</p>
<p>Open the <strong>Eater app</strong> to read the full response.</p>
<p style="color:#999;font-size:12px;margin-top:30px;">Eater App</p>`,
    };
    const transport = getTransporter();
    await transport.sendMail(mail);
}

module.exports = {
    sendPasswordResetEmail,
    sendConsultationRequestEmail,
    sendConsultationReplyEmail,
};
