const nodemailer = require("nodemailer");
const { mailConfig } = require("../config/mail");
const { AppError } = require("./errors");

let transporter;
let isSmtpConfigured = false;

function getTransporter() {
    if (transporter) return transporter;

    if (!mailConfig.host || !mailConfig.user || !mailConfig.pass) {
        console.warn("[Mail] SMTP not configured - email notifications will be disabled");
        isSmtpConfigured = false;
        return null;
    }

    try {
        transporter = nodemailer.createTransport({
            host: mailConfig.host,
            port: mailConfig.port,
            secure: mailConfig.secure,
            auth: {
                user: mailConfig.user,
                pass: mailConfig.pass,
            },
        });
        isSmtpConfigured = true;
        return transporter;
    } catch (error) {
        console.error("[Mail] Failed to initialize transporter:", error.message);
        isSmtpConfigured = false;
        return null;
    }
}

async function sendPasswordResetEmail({ to, otp }) {
    const transport = getTransporter();
    
    if (!transport) {
        console.warn("[Mail] SMTP not configured - password reset email not sent to", to);
        return;
    }

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

    try {
        await transport.sendMail(mail);
    } catch (error) {
        console.error("[Mail] Failed to send password reset email:", error.message);
    }
}

async function sendConsultationEmail({ to, userName, nutritionistName, diagnosis, recommendations, notes }) {
    const transport = getTransporter();
    
    if (!transport) {
        console.warn("[Mail] SMTP not configured - consultation email not sent to", to);
        return;
    }

    const mail = {
        from: mailConfig.from,
        to,
        subject: "📋 Nutritionist Consultation - New Diagnosis & Recommendations",
        text: `Hello ${userName},

Your nutritionist ${nutritionistName} has sent you a new consultation with diagnosis and recommendations.

Diagnosis:
${diagnosis}

Recommendations:
${recommendations}

${notes ? `Additional Notes:\n${notes}\n` : ""}
Please log in to the Eater app to view the full details and discuss with your nutritionist.

Best regards,
Eater Health Team`,
        html: `
<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;">
    <h2 style="color: #2c3e50; margin-bottom: 20px;">📋 New Consultation Received</h2>
    
    <p style="color: #555; font-size: 16px;">Hello <strong>${userName}</strong>,</p>
    
    <p style="color: #555; font-size: 16px;">Your nutritionist <strong>${nutritionistName}</strong> has sent you a new consultation:</p>
    
    <div style="background-color: #f8f9fa; padding: 15px; border-left: 4px solid #3498db; margin: 20px 0;">
        <p style="margin: 0 0 10px 0; color: #2c3e50;"><strong>Diagnosis:</strong></p>
        <p style="margin: 0; color: #555; white-space: pre-wrap;">${diagnosis}</p>
    </div>
    
    <div style="background-color: #f8f9fa; padding: 15px; border-left: 4px solid #27ae60; margin: 20px 0;">
        <p style="margin: 0 0 10px 0; color: #2c3e50;"><strong>Recommendations:</strong></p>
        <p style="margin: 0; color: #555; white-space: pre-wrap;">${recommendations}</p>
    </div>
    
    ${notes ? `<div style="background-color: #f8f9fa; padding: 15px; border-left: 4px solid #f39c12; margin: 20px 0;">
        <p style="margin: 0 0 10px 0; color: #2c3e50;"><strong>Additional Notes:</strong></p>
        <p style="margin: 0; color: #555; white-space: pre-wrap;">${notes}</p>
    </div>` : ""}
    
    <p style="margin-top: 30px; color: #555; font-size: 14px;">
        <a href="http://localhost:5173" style="background-color: #3498db; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;">
            View in Eater App
        </a>
    </p>
    
    <p style="margin-top: 30px; color: #999; font-size: 12px; border-top: 1px solid #e0e0e0; padding-top: 15px;">
        Best regards,<br>
        <strong>Eater Health Team</strong>
    </p>
</div>
        `,
    };

    try {
        await transport.sendMail(mail);
    } catch (error) {
        console.error("[Mail] Failed to send consultation email:", error.message);
    }
}

async function sendNutritionReportEmail({ to, userName, nutritionistName, reportData }) {
    const transport = getTransporter();

    if (!transport) {
        console.warn("[Mail] SMTP not configured - nutrition report email not sent to", to);
        return;
    }

    const consultationCount = reportData?.consultationHistory?.length || 0;
    const mealPlanCount = reportData?.recentMealPlans?.length || 0;
    const patientInfo = reportData?.patientInfo || {};
    const consultationLines = (reportData?.consultationHistory || [])
        .slice(0, 5)
        .map((c, index) => `${index + 1}. [${new Date(c.createdAt).toLocaleDateString()}] ${c.diagnosis} | ${c.recommendations}`)
        .join("\n");
    const mealPlanLines = (reportData?.recentMealPlans || [])
        .slice(0, 5)
        .map((p, index) => `${index + 1}. [${new Date(p.date).toLocaleDateString()}] ${p.targetCalories} kcal | ${p.healthGoal}`)
        .join("\n");

    const healthGoalsText = Array.isArray(patientInfo.healthGoals)
        ? patientInfo.healthGoals.join(", ")
        : (patientInfo.healthGoals || "N/A");
    const allergiesText = Array.isArray(patientInfo.allergies)
        ? patientInfo.allergies.join(", ")
        : (patientInfo.allergies || "N/A");

    const mail = {
        from: mailConfig.from,
        to,
        subject: "Nutrition Report Generated",
        text: `Hello ${userName},

Your nutritionist ${nutritionistName} has generated a nutrition report for you.

    Patient Information:
    - Email: ${patientInfo.email || "N/A"}
    - Age: ${patientInfo.age ?? "N/A"}
    - Gender: ${patientInfo.gender ?? "N/A"}
    - Height: ${patientInfo.height ?? "N/A"}
    - Weight: ${patientInfo.weight ?? "N/A"}
    - Health goals: ${Array.isArray(patientInfo.healthGoals) ? patientInfo.healthGoals.join(", ") : (patientInfo.healthGoals || "N/A")}
    - Allergies: ${Array.isArray(patientInfo.allergies) ? patientInfo.allergies.join(", ") : (patientInfo.allergies || "N/A")}

    Summary:
- Consultations analyzed: ${consultationCount}
- Recent meal plans: ${mealPlanCount}

    Recent Diagnoses:
    ${consultationLines || "No diagnosis history found."}

    Recent Meal Plans:
    ${mealPlanLines || "No meal plans found."}

Please log in to the Eater app to view the full report.

Best regards,
Eater Health Team`,
        html: `
<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;">
    <h2 style="color: #2c3e50; margin-bottom: 20px;">Nutrition Report Generated</h2>
    <p style="color: #555; font-size: 16px;">Hello <strong>${userName}</strong>,</p>
    <p style="color: #555; font-size: 16px;">Your nutritionist <strong>${nutritionistName}</strong> has generated a new nutrition report.</p>

    <div style="background-color: #f8f9fa; padding: 15px; border-left: 4px solid #3498db; margin: 20px 0;">
        <p style="margin: 0 0 8px 0;"><strong>Patient email:</strong> ${patientInfo.email || "N/A"}</p>
        <p style="margin: 0 0 8px 0;"><strong>Age:</strong> ${patientInfo.age ?? "N/A"}</p>
        <p style="margin: 0 0 8px 0;"><strong>Gender:</strong> ${patientInfo.gender ?? "N/A"}</p>
        <p style="margin: 0 0 8px 0;"><strong>Height:</strong> ${patientInfo.height ?? "N/A"}</p>
        <p style="margin: 0 0 8px 0;"><strong>Consultations analyzed:</strong> ${consultationCount}</p>
        <p style="margin: 0 0 8px 0;"><strong>Recent meal plans:</strong> ${mealPlanCount}</p>
        <p style="margin: 0 0 8px 0;"><strong>Current weight:</strong> ${patientInfo.weight ?? "N/A"}</p>
        <p style="margin: 0 0 8px 0;"><strong>Health goals:</strong> ${healthGoalsText}</p>
        <p style="margin: 0;"><strong>Allergies:</strong> ${allergiesText}</p>
    </div>

    <div style="background-color: #fff9e6; padding: 15px; border-left: 4px solid #ffb53e; margin: 20px 0;">
        <p style="margin: 0 0 10px 0;"><strong>Recent Diagnoses:</strong></p>
        <pre style="margin: 0; white-space: pre-wrap; font-family: Arial, sans-serif; color: #444;">${consultationLines || "No diagnosis history found."}</pre>
    </div>

    <div style="background-color: #eefaf0; padding: 15px; border-left: 4px solid #28a745; margin: 20px 0;">
        <p style="margin: 0 0 10px 0;"><strong>Recent Meal Plans:</strong></p>
        <pre style="margin: 0; white-space: pre-wrap; font-family: Arial, sans-serif; color: #444;">${mealPlanLines || "No meal plans found."}</pre>
    </div>

    <p style="margin-top: 30px; color: #555; font-size: 14px;">
        <a href="http://localhost:5173" style="background-color: #3498db; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;">
            View Full Report in Eater App
        </a>
    </p>

    <p style="margin-top: 30px; color: #999; font-size: 12px; border-top: 1px solid #e0e0e0; padding-top: 15px;">
        Best regards,<br>
        <strong>Eater Health Team</strong>
    </p>
</div>
        `,
    };

    try {
        await transport.sendMail(mail);
    } catch (error) {
        console.error("[Mail] Failed to send nutrition report email:", error.message);
    }
}

async function sendMealPlanAssignedEmail({ to, userName, assignedByName, mealPlan }) {
    const transport = getTransporter();

    if (!transport) {
        console.warn("[Mail] SMTP not configured - meal plan assignment email not sent to", to);
        return;
    }

    const planDate = mealPlan?.date ? new Date(mealPlan.date).toLocaleDateString() : "N/A";
    const days = mealPlan?.days || 1;
    const targetCalories = mealPlan?.targetCalories ?? "N/A";
    const healthGoal = mealPlan?.healthGoal || "Maintain Weight";
    const dietTypes = Array.isArray(mealPlan?.dietTypes) && mealPlan.dietTypes.length > 0
        ? mealPlan.dietTypes.join(", ")
        : "N/A";

    const mail = {
        from: mailConfig.from,
        to,
        subject: "New Meal Plan Assigned",
        text: `Hello ${userName},

${assignedByName} has assigned a new personalized meal plan for you.

Meal Plan Summary:
- Start date: ${planDate}
- Duration: ${days} day(s)
- Target calories: ${targetCalories}
- Health goal: ${healthGoal}
- Diet types: ${dietTypes}

Please open the Eater app to review your detailed meal schedule.

Best regards,
Eater Health Team`,
        html: `
<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;">
    <h2 style="color: #2c3e50; margin-bottom: 20px;">New Meal Plan Assigned</h2>
    <p style="color: #555; font-size: 16px;">Hello <strong>${userName}</strong>,</p>
    <p style="color: #555; font-size: 16px;"><strong>${assignedByName}</strong> has assigned a new personalized meal plan for you.</p>

    <div style="background-color: #f8f9fa; padding: 15px; border-left: 4px solid #27ae60; margin: 20px 0;">
        <p style="margin: 0 0 8px 0;"><strong>Start date:</strong> ${planDate}</p>
        <p style="margin: 0 0 8px 0;"><strong>Duration:</strong> ${days} day(s)</p>
        <p style="margin: 0 0 8px 0;"><strong>Target calories:</strong> ${targetCalories}</p>
        <p style="margin: 0 0 8px 0;"><strong>Health goal:</strong> ${healthGoal}</p>
        <p style="margin: 0;"><strong>Diet types:</strong> ${dietTypes}</p>
    </div>

    <p style="margin-top: 30px; color: #555; font-size: 14px;">
        <a href="http://localhost:5173" style="background-color: #3498db; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;">
            View Meal Plan in Eater App
        </a>
    </p>

    <p style="margin-top: 30px; color: #999; font-size: 12px; border-top: 1px solid #e0e0e0; padding-top: 15px;">
        Best regards,<br>
        <strong>Eater Health Team</strong>
    </p>
</div>
        `,
    };

    try {
        await transport.sendMail(mail);
    } catch (error) {
        console.error("[Mail] Failed to send meal plan assignment email:", error.message);
    }
}

module.exports = {
    sendPasswordResetEmail,
    sendConsultationEmail,
    sendNutritionReportEmail,
    sendMealPlanAssignedEmail,
};
