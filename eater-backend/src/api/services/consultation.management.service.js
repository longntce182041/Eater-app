const { MealPlan } = require("../../models/meal_plans");
const { MealPlanItem } = require("../../models/meal_plan_item");
const { Recipe } = require("../../models/Recipe");
const { Nutritionist } = require("../../models/nutritionist");
const Consultation = require("../../models/Consultation");
const User = require("../../models/User");
const UserPro = require("../../models/userPro");
const { User_Profile } = require("../../models/User_Profile");
const { DietaryReferences } = require("../../models/dietary_references");
const { UserHealthMetrics } = require("../../models/user_heath_metrics");
const { ChatMessage } = require("../../models/chat_message");
const { sendConsultationEmail, sendNutritionReportEmail, sendMealPlanAssignedEmail } = require("../../utils/mailer");
const { getRoomId } = require("../sockets/chat.socket");

class ConsultationManagementService {
    
    // Hàm phụ: Kiểm tra quyền bác sĩ
    async getNutritionistProfile(authUserId) {
        const nutri = await Nutritionist.findOne({ userId: authUserId });
        if (!nutri) throw new Error("Nutritionist profile not found. Please update your profile.");
        if (!nutri.verified) throw new Error("Account not verified by Admin yet.");
        return nutri;
    }

    // Hàm phụ: Chỉ cho phép user Pro còn hạn làm việc với chuyên gia dinh dưỡng
    async validateProPatient(userId) {
        const patient = await User.findById(userId).select("email role isActive");
        if (!patient) throw new Error("Patient not found");
        if (patient.role !== "user") throw new Error("Only normal users can be assigned to consultations");
        if (!patient.isActive) throw new Error("Patient account is inactive");

        const now = new Date();
        const activeProPlan = await UserPro.findOne({
            userId: patient._id,
            isActive: true,
            endDate: { $gte: now }
        });

        if (!activeProPlan) {
            throw new Error("This patient is not a Pro user or Pro subscription has expired");
        }

        return patient;
    }

    // Hàm phụ: Gửi notification qua chat + email
    async sendDiagnosisNotification(io, nutritionistUserId, userId, consultation, nutritionistName, userName, userEmail) {
        try {
            // 1. Lưu ChatMessage
            const roomId = getRoomId(nutritionistUserId, userId);
            const messageContent = `📋 **Consultation from ${nutritionistName}**\n\n**Diagnosis:**\n${consultation.diagnosis}\n\n**Recommendations:**\n${consultation.recommendations}${consultation.notes ? `\n\n**Notes:**\n${consultation.notes}` : ""}`;
            
            const chatMsg = await ChatMessage.create({
                roomId: roomId,
                senderId: nutritionistUserId,
                senderRole: "nutritionist",
                content: messageContent,
            });

            // 2. Emit socket event nếu user đang online
            if (io) {
                io.to(roomId).emit("receive_message", {
                    id: chatMsg._id,
                    senderId: chatMsg.senderId,
                    senderRole: chatMsg.senderRole,
                    content: chatMsg.content,
                    createdAt: chatMsg.createdAt,
                });
            }

            // 3. Gửi email thông báo
            if (userEmail) {
                await sendConsultationEmail({
                    to: userEmail,
                    userName: userName,
                    nutritionistName: nutritionistName,
                    diagnosis: consultation.diagnosis,
                    recommendations: consultation.recommendations,
                    notes: consultation.notes || "",
                });
            }
        } catch (error) {
            console.error("Error sending diagnosis notification:", error);
            // Không throw error - chỉ log để không gây ra lỗi khi tạo consultation
        }
    }

    // Hàm phụ: Gửi báo cáo qua chat + email (tuỳ chọn)
    async sendReportNotification(io, nutritionistUserId, userId, reportData, nutritionistName, userName, userEmail, options = {}) {
        try {
            const { sendEmail = false, sendChat = false } = options;

            if (!sendEmail && !sendChat) return;

            if (sendChat) {
                const roomId = getRoomId(nutritionistUserId, userId);
                const messageContent = `Nutrition report from ${nutritionistName}\n\nSummary:\n- Consultations analyzed: ${reportData.consultationHistory.length}\n- Recent meal plans: ${reportData.recentMealPlans.length}\n- Generated at: ${new Date(reportData.generatedAt).toLocaleString()}\n\nPlease open the app to view full report details.`;

                const chatMsg = await ChatMessage.create({
                    roomId: roomId,
                    senderId: nutritionistUserId,
                    senderRole: "nutritionist",
                    content: messageContent,
                });

                if (io) {
                    io.to(roomId).emit("receive_message", {
                        id: chatMsg._id,
                        senderId: chatMsg.senderId,
                        senderRole: chatMsg.senderRole,
                        content: chatMsg.content,
                        createdAt: chatMsg.createdAt,
                    });
                }
            }

            if (sendEmail && userEmail) {
                await sendNutritionReportEmail({
                    to: userEmail,
                    userName: userName,
                    nutritionistName: nutritionistName,
                    reportData,
                });
            }
        } catch (error) {
            console.error("Error sending report notification:", error);
            // Không throw error - chỉ log để không làm hỏng luồng generate report
        }
    }

    // Hàm phụ: Gửi thông báo gán meal plan qua chat + email
    async sendMealPlanAssignmentNotification(io, assignedByUserId, userId, mealPlan, assignedByName, userName, userEmail) {
        try {
            const roomId = getRoomId(assignedByUserId, userId);
            const messageContent = `New meal plan assigned by ${assignedByName}\n\nSummary:\n- Start date: ${new Date(mealPlan.date).toLocaleDateString()}\n- Duration: ${mealPlan.days} day(s)\n- Target calories: ${mealPlan.targetCalories ?? "N/A"}\n- Health goal: ${mealPlan.healthGoal || "Maintain Weight"}\n\nPlease open the app to view your detailed meal plan.`;

            const chatMsg = await ChatMessage.create({
                roomId: roomId,
                senderId: assignedByUserId,
                senderRole: "nutritionist",
                content: messageContent,
            });

            if (io) {
                io.to(roomId).emit("receive_message", {
                    id: chatMsg._id,
                    senderId: chatMsg.senderId,
                    senderRole: chatMsg.senderRole,
                    content: chatMsg.content,
                    createdAt: chatMsg.createdAt,
                });
            }

            if (userEmail) {
                await sendMealPlanAssignedEmail({
                    to: userEmail,
                    userName,
                    assignedByName,
                    mealPlan,
                });
            }
        } catch (error) {
            console.error("Error sending meal plan assignment notification:", error);
            // Không throw error - chỉ log để không làm hỏng luồng tạo meal plan
        }
    }


    // Task: Diagnose Nutrition Condition + Send Recommendations
    // 1. Chẩn đoán & Gửi khuyến nghị
    async createDiagnosisAndRecommendation(authUserId, data, io) {
        const nutri = await this.getNutritionistProfile(authUserId);
        
        // Lấy thông tin user Pro hợp lệ
        const user = await this.validateProPatient(data.userId);
        
        // Lấy profile nutritionist
        const nutritionistUser = await User.findById(authUserId).select("_id");

        const newConsultation = new Consultation({
            userId: data.userId, 
            nutritionistId: nutri._id, 
            diagnosis: data.diagnosis,
            recommendations: data.recommendations,
            notes: data.notes || ""
        });

        const savedConsultation = await newConsultation.save();

        // Gửi thông báo (chat + email)
        await this.sendDiagnosisNotification(
            io,
            nutritionistUser._id,
            data.userId,
            savedConsultation,
            nutri.fullName,
            user.email?.split("@")[0] || "User",
            user.email
        );

        return savedConsultation;
    }


    // Task: Create Personalized Diet Plan + Assign Meal Plan To User
    // 2. Tạo & Gán Thực Đơn cá nhân hóa (cho 1 ngày hoặc 7 ngày)
    async createAndAssignMealPlan(authUserId, data, io) {
        // Allow both nutritionist and admin
        let nutritionistId = null;
        let assignedByName = "Your nutritionist";
        const nutri = await Nutritionist.findOne({ userId: authUserId });
        if (nutri) {
            if (!nutri.verified) throw new Error("Account not verified by Admin yet.");
            nutritionistId = nutri._id;
            assignedByName = nutri.fullName || assignedByName;
        }

        const assignedByUser = await User.findById(authUserId).select("email");
        if (!assignedByName || assignedByName === "Your nutritionist") {
            assignedByName = assignedByUser?.email?.split("@")[0] || "Your nutritionist";
        }

        const patient = await this.validateProPatient(data.userId);

        const newMealPlan = new MealPlan({
            userId: data.userId, 
            nutritionistId: nutritionistId, 
            date: new Date(data.date),
            days: data.days || 1,
            targetCalories: data.targetCalories,
            dietTypes: data.dietTypes || [],
            healthGoal: data.healthGoal || "Maintain Weight",
            status: "active",
            aiGenerated: false,
            metadata: data.metadata || {}
        });

        const savedMealPlan = await newMealPlan.save();

        // Nếu có dữ liệu meals, tạo các MealPlanItem
        if (data.meals && Array.isArray(data.meals) && data.meals.length > 0) {
            const mealPlanItems = [];
            
            for (const meal of data.meals) {
                if (meal.dayIndex >= data.days) {
                    throw new Error(`dayIndex ${meal.dayIndex} exceeds meal plan days ${data.days}`);
                }

                const recipe = await Recipe.findById(meal.recipeId);
                if (!recipe) {
                    throw new Error(`Recipe with ID ${meal.recipeId} not found`);
                }

                const servings = meal.servings || 1;
                const mealPlanItem = new MealPlanItem({
                    mealPlanId: savedMealPlan._id,
                    recipeId: meal.recipeId,
                    mealType: meal.mealType,
                    servings: servings,
                    dayIndex: meal.dayIndex,
                    calories: (recipe.nutritionInfo?.calories || 0) * servings,
                    protein: (recipe.nutritionInfo?.protein || 0) * servings,
                    carbohydrates: (recipe.nutritionInfo?.carbs || 0) * servings,
                    fat: (recipe.nutritionInfo?.fat || 0) * servings,
                    userAction: "none",
                    isLocked: meal.isLocked || false
                });

                mealPlanItems.push(mealPlanItem);
            }

            if (mealPlanItems.length > 0) {
                await MealPlanItem.insertMany(mealPlanItems);
            }
        }

        await this.sendMealPlanAssignmentNotification(
            io,
            authUserId,
            data.userId,
            savedMealPlan,
            assignedByName,
            patient.email?.split("@")[0] || "User",
            patient.email
        );

        return {
            mealPlan: savedMealPlan,
            mealsAdded: data.meals ? data.meals.length : 0
        };
    }

    // 3. Xuất Báo cáo Dinh dưỡng
    async generateNutritionReport(authUserId, patientId, io, options = {}) {
        // Check if user exists (no need to verify nutritionist profile for report generation)
        const nutritionist = await User.findById(authUserId);
        if (!nutritionist) throw new Error("Nutritionist not found");

        const patient = await this.validateProPatient(patientId);

        const profile = await User_Profile.findOne({ userId: patientId });

        const consultations = await Consultation.find({ userId: patientId })
            .sort({ createdAt: -1 })
            .limit(5);

        const recentMealPlans = await MealPlan.find({ userId: patientId })
            .sort({ date: -1 })
            .limit(5);

        const reportData = {
            patientInfo: {
                email: patient.email,
                age: profile?.age,
                gender: profile?.gender,
                height: profile?.height,
                weight: profile?.weight,
                healthGoals: profile?.healthGoals,
                allergies: profile?.allergies
            },
            consultationHistory: consultations,
            recentMealPlans: recentMealPlans,
            generatedAt: new Date()
        };

        const nutritionistProfile = await Nutritionist.findOne({ userId: authUserId }).select("fullName");
        await this.sendReportNotification(
            io,
            authUserId,
            patientId,
            reportData,
            nutritionistProfile?.fullName || "Your nutritionist",
            patient.email?.split("@")[0] || "User",
            patient.email,
            options
        );

        return reportData;
    }


    // Task: View User Health Data
    // 4. Nutritionist xem dữ liệu sức khỏe user
    async getUserHealthData(authUserId, patientId) {
        await this.getNutritionistProfile(authUserId);
        const patient = await this.validateProPatient(patientId);

        const [profile, dietaryReferences, latestHealthMetrics, recentHealthMetrics, latestConsultation, latestMealPlan] = await Promise.all([
            User_Profile.findOne({ userId: patientId }),
            DietaryReferences.findOne({ userId: patientId }).populate("diet_typeId", "name description carb_ratio protein_ratio fat_ratio"),
            UserHealthMetrics.findOne({ userId: patientId }).sort({ calculatedAt: -1 }),
            UserHealthMetrics.find({ userId: patientId }).sort({ calculatedAt: -1 }).limit(10),
            Consultation.findOne({ userId: patientId }).sort({ createdAt: -1 }),
            MealPlan.findOne({ userId: patientId }).sort({ date: -1 }),
        ]);

        return {
            patientInfo: {
                userId: patient._id,
                email: patient.email,
                isActive: patient.isActive,
            },
            profile,
            dietaryReferences,
            latestHealthMetrics,
            recentHealthMetrics,
            latestConsultation,
            latestMealPlan,
            generatedAt: new Date(),
        };
    }
}

module.exports = new ConsultationManagementService();