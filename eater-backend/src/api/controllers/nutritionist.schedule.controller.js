const { NutritionistSchedule } = require("../../models/nutritionist_schedule");
const { ScheduleChangeRequest } = require("../../models/schedule_change_request");
const User = require("../../models/User");

// Admin: list nutritionists for schedule assignment
exports.getNutritionistsForScheduling = async (req, res) => {
  try {
    const availableOnly = String(req.query?.availableOnly || "false") === "true";

    const nutritionists = await User.find({ role: "nutritionist", isActive: true })
      .select("email _id")
      .sort({ email: 1 });

    const activeSchedules = await NutritionistSchedule.find({ status: "active" })
      .select("userId nutritionistId");

    const scheduledUserIds = new Set(
      activeSchedules
        .map((s) => s.userId || s.nutritionistId)
        .filter(Boolean)
        .map((id) => String(id))
    );

    let data = nutritionists.map((u) => ({
      id: u._id,
      fullName: u.email,
      specialization: "Nutritionist",
      email: u.email,
      userId: u._id,
      hasActiveSchedule: scheduledUserIds.has(String(u._id)),
    }));

    if (availableOnly) {
      data = data.filter((u) => !u.hasActiveSchedule);
    }

    return res.status(200).json({ success: true, data });
  } catch (err) {
    console.error("Error fetching nutritionists for scheduling:", err);
    return res.status(500).json({ success: false, message: err.message });
  }
};

// Admin: Create a new schedule for nutritionist
exports.createSchedule = async (req, res) => {
  try {
    const { nutritionistId, nutritionistIds, workDays, specialDays } = req.body;

    const targetIds = Array.isArray(nutritionistIds) && nutritionistIds.length > 0
      ? nutritionistIds
      : nutritionistId
        ? [nutritionistId]
        : [];

    console.log(
      "📅 Creating schedule(s) - Req body:",
      JSON.stringify(
        {
          targetCount: targetIds.length,
          workDaysCount: workDays?.length,
          specialDaysCount: specialDays?.length,
        },
        null,
        2
      )
    );

    // Validate input
    if (targetIds.length === 0 || !workDays || workDays.length === 0) {
      return res.status(400).json({
        success: false,
        message: "nutritionistIds (or nutritionistId) and workDays array are required",
      });
    }

    // Verify users exist and are nutritionists
    const nutritionistUsers = await User.find({
      _id: { $in: targetIds },
      role: "nutritionist",
    }).select("_id role email");

    const validIdSet = new Set(nutritionistUsers.map((u) => String(u._id)));
    const invalidIds = targetIds.filter((id) => !validIdSet.has(String(id)));

    const created = [];
    const updated = [];
    const skipped = [];

    for (const id of targetIds) {
      const userId = String(id);

      if (!validIdSet.has(userId)) {
        skipped.push({ nutritionistId: userId, reason: "Nutritionist user not found" });
        continue;
      }

      const existingSchedule = await NutritionistSchedule.findOne({
        userId,
        status: "active",
      });

      if (existingSchedule) {
        const existingWorkDayDates = new Set(
          (existingSchedule.workDays || []).map((day) => day.date)
        );

        const incomingWorkDays = Array.isArray(workDays) ? workDays : [];
        const newWorkDays = incomingWorkDays.filter(
          (day) => day?.date && !existingWorkDayDates.has(day.date)
        );

        if (newWorkDays.length === 0) {
          skipped.push({
            nutritionistId: userId,
            reason: "All provided work days already exist in active schedule",
          });
          continue;
        }

        const mergedWorkDays = [...(existingSchedule.workDays || []), ...newWorkDays].sort(
          (a, b) => String(a.date).localeCompare(String(b.date))
        );

        const existingSpecialDayDates = new Set(
          (existingSchedule.specialDays || []).map((day) => day.date)
        );

        const incomingSpecialDays = Array.isArray(specialDays) ? specialDays : [];
        const newSpecialDays = incomingSpecialDays.filter(
          (day) => day?.date && !existingSpecialDayDates.has(day.date)
        );

        existingSchedule.workDays = mergedWorkDays;
        existingSchedule.specialDays = [
          ...(existingSchedule.specialDays || []),
          ...newSpecialDays,
        ];

        await existingSchedule.save();
        updated.push(existingSchedule);
        continue;
      }

      const newSchedule = await NutritionistSchedule.create({
        nutritionistId: userId,
        userId,
        workDays: workDays || [],
        specialDays: specialDays || [],
        status: "active",
      });

      created.push(newSchedule);
    }

    if (created.length === 0 && updated.length === 0) {
      return res.status(400).json({
        success: false,
        message: "No schedules were created",
        invalidIds,
        skipped,
      });
    }

    return res.status(201).json({
      success: true,
      message: `Created ${created.length} schedule(s), updated ${updated.length} schedule(s)`,
      data: [...created, ...updated],
      createdCount: created.length,
      updatedCount: updated.length,
      skippedCount: skipped.length,
      skipped,
      invalidIds,
    });
  } catch (err) {
    console.error("❌ Error creating schedule:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

// Get all schedules (Admin)
exports.getAllSchedules = async (req, res) => {
  try {
    // Trả dữ liệu cho màn admin Manage Schedule (list/card + search/filter phía FE).
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

    // Hỗ trợ admin xem chi tiết một lịch cụ thể.
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

    // Chỉ cập nhật các trường FE gửi lên để tránh ghi đè ngoài ý muốn.
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

    // Xóa hẳn schedule theo thao tác Delete từ admin.
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
    const MIN_WORK_TIME = "09:00";
    const MAX_WORK_TIME = "17:00";

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

    if (requestType === "modify_hours") {
      const startTime = String(proposedChanges?.startTime || "");
      const endTime = String(proposedChanges?.endTime || "");

      if (!startTime || !endTime) {
        return res.status(400).json({
          success: false,
          message: "modify_hours requires startTime and endTime",
        });
      }

      if (
        startTime < MIN_WORK_TIME ||
        startTime > MAX_WORK_TIME ||
        endTime < MIN_WORK_TIME ||
        endTime > MAX_WORK_TIME
      ) {
        return res.status(400).json({
          success: false,
          message: `modify_hours must be within ${MIN_WORK_TIME}-${MAX_WORK_TIME}`,
        });
      }

      if (startTime >= endTime) {
        return res.status(400).json({
          success: false,
          message: "endTime must be later than startTime",
        });
      }
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
    const timeToMinutes = (timeStr) => {
      if (!timeStr || !String(timeStr).includes(":")) return null;
      const [hourStr, minuteStr] = String(timeStr).split(":");
      const hours = Number(hourStr);
      const minutes = Number(minuteStr);
      if (!Number.isFinite(hours) || !Number.isFinite(minutes)) return null;
      return hours * 60 + minutes;
    };
    const minutesToTime = (totalMinutes) => {
      const safeMinutes = Math.max(0, Math.floor(totalMinutes));
      const hours = String(Math.floor(safeMinutes / 60)).padStart(2, "0");
      const minutes = String(safeMinutes % 60).padStart(2, "0");
      return `${hours}:${minutes}`;
    };
    const addDaysToDateStr = (dateStr, days) => {
      const date = new Date(`${dateStr}T00:00:00`);
      date.setDate(date.getDate() + days);
      return toDateStr(date);
    };
    const upsertSpecialDay = ({ date, type, reason, isAvailable = false }) => {
      schedule.specialDays = schedule.specialDays || [];
      const existingIndex = schedule.specialDays.findIndex((d) => d.date === date);
      if (existingIndex !== -1) {
        schedule.specialDays[existingIndex].type = type;
        schedule.specialDays[existingIndex].reason = reason;
        schedule.specialDays[existingIndex].isAvailable = isAvailable;
      } else {
        schedule.specialDays.push({ date, type, reason, isAvailable });
      }
    };

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
      const targetStartDate = toDateStr(changeRequest.affectedDates.startDate);
      const requestedOffHours = Number(changeRequest.proposedChanges?.offHours || 0);
      const requestedOffDays = Number(changeRequest.proposedChanges?.offDays || 0);

      // Partial leave: subtract requested hours directly from the target workday.
      if (requestedOffHours > 0) {
        const dayIndex = (schedule.workDays || []).findIndex(
          (d) => d.date === targetStartDate
        );

        if (dayIndex !== -1) {
          const workDay = schedule.workDays[dayIndex];
          const startMinutes = timeToMinutes(workDay.startTime);
          const endMinutes = timeToMinutes(workDay.endTime);

          if (startMinutes !== null && endMinutes !== null && endMinutes > startMinutes) {
            const deductedMinutes = endMinutes - requestedOffHours * 60;

            if (deductedMinutes <= startMinutes) {
              workDay.isAvailable = false;
              upsertSpecialDay({
                date: targetStartDate,
                type: "off",
                reason: `${changeRequest.reason} (Approved ${requestedOffHours} hours off)`,
                isAvailable: false,
              });
            } else {
              workDay.endTime = minutesToTime(deductedMinutes);
              upsertSpecialDay({
                date: targetStartDate,
                type: "special_event",
                reason: `${changeRequest.reason} (Approved ${requestedOffHours} hours off)`,
                isAvailable: true,
              });
            }
          }
        }
      } else {
        const rangeEndDate = changeRequest.affectedDates?.endDate
          ? toDateStr(changeRequest.affectedDates.endDate)
          : requestedOffDays > 1
            ? addDaysToDateStr(targetStartDate, requestedOffDays - 1)
            : targetStartDate;

        const cursor = new Date(`${targetStartDate}T00:00:00`);
        const end = new Date(`${rangeEndDate}T00:00:00`);

        while (cursor <= end) {
          const currentDate = toDateStr(cursor);
          const dayIndex = (schedule.workDays || []).findIndex((d) => d.date === currentDate);
          if (dayIndex !== -1) {
            schedule.workDays[dayIndex].isAvailable = false;
          }

          upsertSpecialDay({
            date: currentDate,
            type: "off",
            reason: changeRequest.reason,
            isAvailable: false,
          });

          cursor.setDate(cursor.getDate() + 1);
        }
      }
    } else if (changeRequest.requestType === "vacation") {
      const startDate = new Date(changeRequest.affectedDates.startDate);
      const endDate = new Date(changeRequest.affectedDates.endDate || startDate);

      while (startDate <= endDate) {
        const currentDate = startDate.toISOString().split("T")[0];
        const dayIndex = (schedule.workDays || []).findIndex((d) => d.date === currentDate);
        if (dayIndex !== -1) {
          schedule.workDays[dayIndex].isAvailable = false;
        }

        upsertSpecialDay({
          date: currentDate,
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
