const { NutritionistSchedule } = require("../../models/nutritionist_schedule");
const { ScheduleChangeRequest } = require("../../models/schedule_change_request");
const User = require("../../models/User");

// Admin: list nutritionists for schedule assignment
exports.getNutritionistsForScheduling = async (req, res) => {
  try {
    const nutritionists = await User.find({ role: "nutritionist", isActive: true })
      .select("email _id")
      .sort({ email: 1 });

    const data = nutritionists.map((u) => ({
      id: u._id,
      fullName: u.email,
      specialization: "Nutritionist",
      email: u.email,
      userId: u._id,
    }));

    return res.status(200).json({ success: true, data });
  } catch (err) {
    console.error("Error fetching nutritionists for scheduling:", err);
    return res.status(500).json({ success: false, message: err.message });
  }
};

// Admin: Create a new schedule for nutritionist
exports.createSchedule = async (req, res) => {
  try {
    const { nutritionistId, workDays, specialDays } = req.body;

    console.log("📅 Creating schedule - Req body:", JSON.stringify({ nutritionistId, workDaysCount: workDays?.length, specialDaysCount: specialDays?.length }, null, 2));

    // Validate input
    if (!nutritionistId || !workDays || workDays.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: "nutritionistId and workDays array are required" 
      });
    }

    // Verify user exists and is a nutritionist
    const nutritionistUser = await User.findById(nutritionistId).select("_id role email");
    if (!nutritionistUser || nutritionistUser.role !== "nutritionist") {
      return res.status(404).json({ success: false, message: "Nutritionist user not found" });
    }

    // Check if schedule already exists for this nutritionist
    const existingSchedule = await NutritionistSchedule.findOne({
      userId: nutritionistId,
      status: "active",
    });

    if (existingSchedule) {
      return res.status(400).json({
        success: false,
        message: "Active schedule already exists for this nutritionist",
      });
    }

    const newSchedule = new NutritionistSchedule({
      nutritionistId,
      userId: nutritionistId,
      workDays: workDays || [],
      specialDays: specialDays || [],
      status: "active",
    });

    await newSchedule.save();

    console.log("✅ Schedule created:", newSchedule._id);

    res.status(201).json({
      success: true,
      message: "Schedule created successfully",
      data: newSchedule,
    });
  } catch (err) {
    console.error("❌ Error creating schedule:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

// Get all schedules (Admin)
exports.getAllSchedules = async (req, res) => {
  try {
    const schedules = await NutritionistSchedule.find()
      .populate("nutritionistId", "email role")
      .populate("userId", "email")
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: schedules.length,
      data: schedules,
    });
  } catch (err) {
    console.error("Error fetching schedules:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

// Get nutritionist's current schedule
exports.getNutritionistSchedule = async (req, res) => {
  try {
    let nutritionistUserId = req.params.nutritionistId;

    // /my-schedule path: use current logged-in user id
    if (!nutritionistUserId && req.user?.id) {
      nutritionistUserId = req.user.id;
    }

    if (!nutritionistUserId) {
      return res.status(404).json({
        success: false,
        message: "Nutritionist user not found",
      });
    }

    const schedule = await NutritionistSchedule.findOne({
      userId: nutritionistUserId,
      status: "active",
    }).populate("nutritionistId", "email role");

    if (!schedule) {
      return res.status(404).json({
        success: false,
        message: "No active schedule found for this nutritionist",
      });
    }

    res.status(200).json({
      success: true,
      data: schedule,
    });
  } catch (err) {
    console.error("Error fetching nutritionist schedule:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

// Get schedule by ID
exports.getScheduleById = async (req, res) => {
  try {
    const { scheduleId } = req.params;

    const schedule = await NutritionistSchedule.findById(scheduleId)
      .populate("nutritionistId", "email role")
      .populate("userId", "email");

    if (!schedule) {
      return res.status(404).json({
        success: false,
        message: "Schedule not found",
      });
    }

    res.status(200).json({
      success: true,
      data: schedule,
    });
  } catch (err) {
    console.error("Error fetching schedule:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

// Admin: Update schedule
exports.updateSchedule = async (req, res) => {
  try {
    const { scheduleId } = req.params;
    const { workDays, specialDays, status } = req.body;

    const schedule = await NutritionistSchedule.findByIdAndUpdate(
      scheduleId,
      {
        ...(workDays && { workDays }),
        ...(specialDays && { specialDays }),
        ...(status && { status }),
      },
      { new: true }
    );

    if (!schedule) {
      return res.status(404).json({
        success: false,
        message: "Schedule not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Schedule updated successfully",
      data: schedule,
    });
  } catch (err) {
    console.error("Error updating schedule:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

// Admin: Delete schedule
exports.deleteSchedule = async (req, res) => {
  try {
    const { scheduleId } = req.params;

    const schedule = await NutritionistSchedule.findByIdAndDelete(scheduleId);

    if (!schedule) {
      return res.status(404).json({
        success: false,
        message: "Schedule not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Schedule deleted successfully",
    });
  } catch (err) {
    console.error("Error deleting schedule:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

// Nutritionist: Request schedule change
exports.requestScheduleChange = async (req, res) => {
  try {
    const userId = req.user?.id; // From auth middleware
    const { scheduleId, requestType, affectedDates, proposedChanges, reason } = req.body;

    // Verify the schedule exists
    const schedule = await NutritionistSchedule.findById(scheduleId);
    if (!schedule) {
      return res.status(404).json({
        success: false,
        message: "Schedule not found",
      });
    }

    // Verify nutritionist owns this schedule
    if (schedule.userId.toString() !== userId) {
      return res.status(403).json({
        success: false,
        message: "Unauthorized: You can only request changes for your own schedule",
      });
    }

    const changeRequest = new ScheduleChangeRequest({
      nutritionistId: schedule.nutritionistId,
      userId,
      scheduleId,
      requestType,
      affectedDates,
      proposedChanges,
      reason,
    });

    await changeRequest.save();

    res.status(201).json({
      success: true,
      message: "Schedule change request submitted successfully",
      data: changeRequest,
    });
  } catch (err) {
    console.error("Error creating change request:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

// Get pending change requests for a nutritionist
exports.getNutritionistChangeRequests = async (req, res) => {
  try {
    const { nutritionistId } = req.params;
    const { status } = req.query;

    const query = { nutritionistId };
    if (status) query.status = status;

    const changeRequests = await ScheduleChangeRequest.find(query)
      .populate("nutritionistId", "email role")
      .populate("userId", "email")
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: changeRequests.length,
      data: changeRequests,
    });
  } catch (err) {
    console.error("Error fetching change requests:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

// Get all pending change requests (Admin)
exports.getAllChangeRequests = async (req, res) => {
  try {
    const { status } = req.query;

    const query = {};
    if (status) query.status = status;

    const changeRequests = await ScheduleChangeRequest.find(query)
      .populate("nutritionistId", "email role")
      .populate("userId", "email")
      .populate("approvedBy", "email")
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: changeRequests.length,
      data: changeRequests,
    });
  } catch (err) {
    console.error("Error fetching change requests:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

// Admin: Approve schedule change request
exports.approveChangeRequest = async (req, res) => {
  try {
    const { requestId } = req.params;
    const adminId = req.user?.id; // From auth middleware
    const { adminNotes } = req.body;

    const changeRequest = await ScheduleChangeRequest.findById(requestId);
    if (!changeRequest) {
      return res.status(404).json({
        success: false,
        message: "Change request not found",
      });
    }

    // Update the schedule based on the request
    const schedule = await NutritionistSchedule.findById(changeRequest.scheduleId);
    if (!schedule) {
      return res.status(404).json({ success: false, message: "Schedule not found" });
    }

    const toDateStr = (d) => new Date(d).toISOString().split("T")[0];

    if (changeRequest.requestType === "modify_hours" && changeRequest.proposedChanges) {
      const targetDate = changeRequest.proposedChanges.date || toDateStr(changeRequest.affectedDates.startDate);
      const dayIndex = (schedule.workDays || []).findIndex((d) => d.date === targetDate);
      if (dayIndex !== -1) {
        if (changeRequest.proposedChanges.startTime) {
          schedule.workDays[dayIndex].startTime = changeRequest.proposedChanges.startTime;
        }
        if (changeRequest.proposedChanges.endTime) {
          schedule.workDays[dayIndex].endTime = changeRequest.proposedChanges.endTime;
        }
      }
    } else if (changeRequest.requestType === "take_day_off") {
      schedule.specialDays = schedule.specialDays || [];
      schedule.specialDays.push({
        date: toDateStr(changeRequest.affectedDates.startDate),
        type: "off",
        reason: changeRequest.reason,
        isAvailable: false,
      });
    } else if (changeRequest.requestType === "vacation") {
      schedule.specialDays = schedule.specialDays || [];
      const startDate = new Date(changeRequest.affectedDates.startDate);
      const endDate = new Date(changeRequest.affectedDates.endDate || startDate);

      while (startDate <= endDate) {
        schedule.specialDays.push({
          date: startDate.toISOString().split("T")[0],
          type: "vacation",
          reason: changeRequest.reason,
          isAvailable: false,
        });
        startDate.setDate(startDate.getDate() + 1);
      }
    }

    await schedule.save();

    // Update change request status
    changeRequest.status = "approved";
    changeRequest.adminNotes = adminNotes;
    changeRequest.approvedBy = adminId;
    changeRequest.approvedAt = new Date();

    await changeRequest.save();

    res.status(200).json({
      success: true,
      message: "Schedule change request approved successfully",
      data: changeRequest,
    });
  } catch (err) {
    console.error("Error approving change request:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

// Admin: Reject schedule change request
exports.rejectChangeRequest = async (req, res) => {
  try {
    const { requestId } = req.params;
    const { adminNotes } = req.body;

    const changeRequest = await ScheduleChangeRequest.findById(requestId);
    if (!changeRequest) {
      return res.status(404).json({
        success: false,
        message: "Change request not found",
      });
    }

    changeRequest.status = "rejected";
    changeRequest.adminNotes = adminNotes;
    changeRequest.rejectedAt = new Date();

    await changeRequest.save();

    res.status(200).json({
      success: true,
      message: "Schedule change request rejected",
      data: changeRequest,
    });
  } catch (err) {
    console.error("Error rejecting change request:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};
