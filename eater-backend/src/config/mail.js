const mailConfig = {
    host: process.env.SMTP_HOST || "",
    port: Number(process.env.SMTP_PORT || 587),
    secure: process.env.SMTP_SECURE === "true", // true for 465, false for others
    user: process.env.SMTP_USER || "",
    pass: process.env.SMTP_PASS || "",
    from: process.env.SMTP_FROM || process.env.SMTP_USER || "no-reply@example.com",
    resetPasswordUrl:
        process.env.RESET_PASSWORD_URL || "http://localhost:5173/reset-password",
};

module.exports = { mailConfig };
