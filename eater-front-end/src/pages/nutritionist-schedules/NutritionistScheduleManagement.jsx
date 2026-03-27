import React, { useState, useEffect } from "react";
import {
  Plus,
  Edit2,
  Trash2,
  ChevronDown,
  X,
  AlertCircle,
} from "lucide-react";
import {
  getAllNutritionistSchedules,
  createNutritionistSchedule,
  updateNutritionistSchedule,
  deleteNutritionistSchedule,
  getAllNutritionists,
} from "@/services/nutritionistScheduleApi";
import "./NutritionistScheduleManagement.css";

const MIN_WORK_TIME = "09:00";
const MAX_WORK_TIME = "17:00";

const formatDateKey = (date) => {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
};

const getCurrentMonthValue = () => {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, "0");
  return `${year}-${month}`;
};

const getMonthFromWorkDays = (workDays) => {
  if (!Array.isArray(workDays) || workDays.length === 0 || !workDays[0]?.date) {
    return getCurrentMonthValue();
  }
  return String(workDays[0].date).slice(0, 7);
};

const generateWorkDaysForMonth = (monthValue, { includePastDays = false } = {}) => {
  if (!monthValue || !monthValue.includes("-")) {
    return [];
  }

  const [yearStr, monthStr] = monthValue.split("-");
  const year = Number(yearStr);
  const month = Number(monthStr);
  if (!Number.isInteger(year) || !Number.isInteger(month) || month < 1 || month > 12) {
    return [];
  }

  const totalDays = new Date(year, month, 0).getDate();
  const workDays = [];
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  for (let day = 1; day <= totalDays; day += 1) {
    const date = new Date(year, month - 1, day);
    if (date.getDay() === 0) {
      continue;
    }

    if (!includePastDays && date < today) {
      continue;
    }

    workDays.push({
      date: formatDateKey(date),
      startTime: MIN_WORK_TIME,
      endTime: MAX_WORK_TIME,
      isAvailable: true,
    });
  }

  return workDays;
};

const clampTime = (timeValue) => {
  if (!timeValue) return MIN_WORK_TIME;
  if (timeValue < MIN_WORK_TIME) return MIN_WORK_TIME;
  if (timeValue > MAX_WORK_TIME) return MAX_WORK_TIME;
  return timeValue;
};

const normalizeWorkDays = (workDays) => {
  if (!Array.isArray(workDays)) return [];

  return workDays
    .filter((day) => {
      if (!day?.date) return false;
      const weekday = new Date(`${day.date}T00:00:00`).getDay();
      return weekday !== 0;
    })
    .map((day) => ({
      ...day,
      startTime: clampTime(day.startTime),
      endTime: clampTime(day.endTime),
    }));
};

const NutritionistScheduleManagement = () => {
  const [schedules, setSchedules] = useState([]);
  const [nutritionists, setNutritionists] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [editingSchedule, setEditingSchedule] = useState(null);
  const [selectedSchedule, setSelectedSchedule] = useState(null);
  const [selectedMonth, setSelectedMonth] = useState(getCurrentMonthValue());
  const [formData, setFormData] = useState({
    nutritionistIds: [],
    workDays: generateWorkDaysForMonth(getCurrentMonthValue(), {
      includePastDays: false,
    }),
    specialDays: [],
  });

  useEffect(() => {
    fetchSchedules();
    fetchNutritionists();
  }, []);

  const fetchNutritionists = async () => {
    try {
      const data = await getAllNutritionists({ availableOnly: false });
      setNutritionists(data || []);
    } catch (err) {
      console.error("Error fetching nutritionists:", err);
    }
  };

  const fetchSchedules = async () => {
    try {
      setLoading(true);
      const data = await getAllNutritionistSchedules();
      setSchedules(data || []);
      setError(null);
    } catch (err) {
      setError(err.message || "Failed to load schedules");
      console.error("Error fetching schedules:", err);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateSchedule = async (e) => {
    e.preventDefault();
    try {
      const normalizedWorkDays = normalizeWorkDays(formData.workDays);

      if (!Array.isArray(normalizedWorkDays) || normalizedWorkDays.length === 0) {
        setError("Work days are required");
        return;
      }

      const invalidRangeDay = normalizedWorkDays.find(
        (day) => day.startTime >= day.endTime
      );
      if (invalidRangeDay) {
        setError(`Invalid time range on ${invalidRangeDay.date}. End time must be after start time.`);
        return;
      }

      if (!Array.isArray(formData.nutritionistIds) || formData.nutritionistIds.length === 0) {
        setError("Please select at least one nutritionist");
        return;
      }

      // Check token exists
      const token = localStorage.getItem("token");
      if (!token) {
        setError("No authentication token found. Please login again.");
        return;
      }

      const userRole = localStorage.getItem("userRole");
      if (userRole !== "admin") {
        setError(`Admin access required. Your role: ${userRole}`);
        return;
      }

      const payload = {
        ...formData,
        workDays: normalizedWorkDays,
      };

      const result = await createNutritionistSchedule(payload);
      if (result?.skippedCount > 0) {
        const firstReason = result?.skipped?.[0]?.reason || "Some schedules were skipped";
        setError(`Created ${result.createdCount} schedule(s), skipped ${result.skippedCount}: ${firstReason}`);
      }
      fetchSchedules();
      fetchNutritionists();
      resetForm();
      setShowForm(false);
    } catch (err) {
      setError(err.response?.data?.message || err.message || "Failed to create schedule");
      console.error("Error creating schedule:", err);
    }
  };

  const handleUpdateSchedule = async (e) => {
    e.preventDefault();
    if (!editingSchedule) return;

    try {
      const normalizedWorkDays = normalizeWorkDays(formData.workDays);
      if (!normalizedWorkDays.length) {
        setError("Work days are required");
        return;
      }

      const invalidRangeDay = normalizedWorkDays.find(
        (day) => day.startTime >= day.endTime
      );
      if (invalidRangeDay) {
        setError(`Invalid time range on ${invalidRangeDay.date}. End time must be after start time.`);
        return;
      }

      await updateNutritionistSchedule(editingSchedule._id, {
        ...formData,
        workDays: normalizedWorkDays,
      });
      fetchSchedules();
      fetchNutritionists();
      resetForm();
      setEditingSchedule(null);
      setShowForm(false);
    } catch (err) {
      setError(err.message || "Failed to update schedule");
      console.error("Error updating schedule:", err);
    }
  };

  const handleDeleteSchedule = async (scheduleId) => {
    if (!confirm("Are you sure you want to delete this schedule?")) return;

    try {
      await deleteNutritionistSchedule(scheduleId);
      fetchSchedules();
      fetchNutritionists();
      setSelectedSchedule(null);
    } catch (err) {
      setError(err.message || "Failed to delete schedule");
      console.error("Error deleting schedule:", err);
    }
  };

  const resetForm = () => {
    const monthValue = getCurrentMonthValue();
    setSelectedMonth(monthValue);
    setFormData({
      nutritionistIds: [],
      workDays: generateWorkDaysForMonth(monthValue, {
        includePastDays: false,
      }),
      specialDays: [],
    });
    setEditingSchedule(null);
  };

  const handleEditClick = (schedule) => {
    const monthValue = getMonthFromWorkDays(schedule.workDays);
    setSelectedMonth(monthValue);
    setEditingSchedule(schedule);
    setFormData({
      nutritionistIds: [schedule.nutritionistId._id],
      workDays: normalizeWorkDays(schedule.workDays),
      specialDays: schedule.specialDays,
    });
    setShowForm(true);
  };

  const handleScheduleDetailChange = (dayIndex, field, value) => {
    const updatedWorkDays = [...formData.workDays];
    if (field === "startTime" || field === "endTime") {
      updatedWorkDays[dayIndex][field] = clampTime(value);
    } else {
      updatedWorkDays[dayIndex][field] = value;
    }
    setFormData({ ...formData, workDays: updatedWorkDays });
  };

  const handleMonthChange = (monthValue) => {
    setSelectedMonth(monthValue);
    setFormData((prev) => ({
      ...prev,
      workDays: generateWorkDaysForMonth(monthValue, {
        includePastDays: Boolean(editingSchedule),
      }),
    }));
  };

  const normalizedSearch = searchTerm.trim().toLowerCase();
  const filteredSchedules = schedules.filter((schedule) => {
    if (!normalizedSearch) return true;

    const email = schedule.nutritionistId?.email?.toLowerCase() || "";
    const role = schedule.nutritionistId?.role?.toLowerCase() || "";
    const status = schedule.status?.toLowerCase() || "";
    const dates = Array.isArray(schedule.workDays)
      ? schedule.workDays.map((d) => String(d.date || "").toLowerCase()).join(" ")
      : "";

    return (
      email.includes(normalizedSearch) ||
      role.includes(normalizedSearch) ||
      status.includes(normalizedSearch) ||
      dates.includes(normalizedSearch)
    );
  });

  if (loading) {
    return <div className="loading">Loading schedules...</div>;
  }

  return (
    <div className="nutritionist-schedule-management">
      <div className="schedule-header">
        <h1>Nutritionist Schedule Management</h1>
        <button
          className="btn btn-primary"
          onClick={() => {
            resetForm();
            setShowForm(true);
          }}
        >
          <Plus size={20} /> Create New Schedule
        </button>
      </div>

      <div className="schedule-toolbar">
        <input
          type="text"
          className="schedule-search-input"
          placeholder="Search by email, status, role, or date (YYYY-MM-DD)..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
        <span className="schedule-search-count">
          Showing {filteredSchedules.length}/{schedules.length}
        </span>
      </div>

      {error && (
        <div className="alert alert-error">
          <AlertCircle size={20} />
          <span>{error}</span>
          <button onClick={() => setError(null)}>
            <X size={16} />
          </button>
        </div>
      )}

      {showForm && (
        <ScheduleForm
          formData={formData}
          nutritionists={nutritionists}
          editingSchedule={editingSchedule}
          onSubmit={editingSchedule ? handleUpdateSchedule : handleCreateSchedule}
          onCancel={() => {
            setShowForm(false);
            resetForm();
          }}
          onScheduleDetailChange={handleScheduleDetailChange}
          setFormData={setFormData}
          selectedMonth={selectedMonth}
          onMonthChange={handleMonthChange}
        />
      )}

      <div className="schedules-grid">
        {schedules.length === 0 ? (
          <div className="empty-state">
            <p>No schedules created yet</p>
            <button
              className="btn btn-primary"
              onClick={() => {
                resetForm();
                setShowForm(true);
              }}
            >
              Create First Schedule
            </button>
          </div>
        ) : filteredSchedules.length === 0 ? (
          <div className="empty-state">
            <p>No schedules match your search</p>
          </div>
        ) : (
          filteredSchedules.map((schedule) => (
            <div key={schedule._id} className="schedule-card">
              <div className="schedule-card-header">
                <div>
                  <h3>{schedule.nutritionistId?.email || "Nutritionist"}</h3>
                  <p className="specialization">
                    {schedule.nutritionistId?.role || "nutritionist"}
                  </p>
                </div>
                <span className={`status-badge status-${schedule.status}`}>
                  {schedule.status}
                </span>
              </div>

              <div className="schedule-info">
                <p>
                  <strong>Total Work Days:</strong> {schedule.workDays?.length || 0}
                </p>
              </div>

              <div className="schedule-actions">
                <button
                  className="btn btn-secondary"
                  onClick={() => setSelectedSchedule(schedule)}
                >
                  View Details
                </button>
                <button
                  className="btn btn-warning"
                  onClick={() => handleEditClick(schedule)}
                >
                  <Edit2 size={16} /> Edit
                </button>
                <button
                  className="btn btn-danger"
                  onClick={() => handleDeleteSchedule(schedule._id)}
                >
                  <Trash2 size={16} /> Delete
                </button>
              </div>
            </div>
          ))
        )}
      </div>

      {selectedSchedule && (
        <ScheduleDetailModal
          schedule={selectedSchedule}
          onClose={() => setSelectedSchedule(null)}
        />
      )}
    </div>
  );
};

const ScheduleForm = ({
  formData,
  nutritionists,
  editingSchedule,
  onSubmit,
  onCancel,
  onScheduleDetailChange,
  setFormData,
  selectedMonth,
  onMonthChange,
}) => {
  return (
    <div className="modal-overlay" onClick={onCancel}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h2>{editingSchedule ? "Edit Schedule" : "Create New Schedule"}</h2>
          <button className="btn-close" onClick={onCancel}>
            <X size={24} />
          </button>
        </div>

        <form onSubmit={onSubmit} className="schedule-form">
          {!editingSchedule && (
            <div className="form-group">
              <label htmlFor="nutritionistIds">Nutritionists *</label>
              <select
                id="nutritionistIds"
                multiple
                size={Math.min(8, Math.max(4, nutritionists.length || 4))}
                value={formData.nutritionistIds}
                onChange={(e) =>
                  setFormData({
                    ...formData,
                    nutritionistIds: Array.from(e.target.selectedOptions, (opt) => opt.value),
                  })
                }
                required
              >
                {nutritionists.map((nut) => (
                  <option key={nut.id} value={nut.id}>
                    {nut.fullName} ({nut.email})
                  </option>
                ))}
              </select>
              <small style={{ color: "#666" }}>Hold Ctrl/Cmd to select multiple nutritionists.</small>
            </div>
          )}

          <div className="form-group month-picker-group">
            <label htmlFor="scheduleMonth">Schedule Month *</label>
            <input
              id="scheduleMonth"
              type="month"
              value={selectedMonth}
              onChange={(e) => onMonthChange(e.target.value)}
              required
            />
            <small className="month-picker-note">
              Auto-generates all dates in selected month and excludes Sundays.
            </small>
          </div>

          <div className="section-title">Work Days Schedule ({formData.workDays.length} days)</div>
          <div className="schedule-details">
            {formData.workDays.map((day, index) => {
              const dateObj = new Date(day.date);
              const dayName = dateObj.toLocaleDateString("en-US", { weekday: "short" });
              return (
                <div key={index} className="day-schedule">
                  <div className="day-name">{day.date} ({dayName})</div>
                  <div className="time-inputs">
                    <input
                      type="time"
                      value={day.startTime}
                      min={MIN_WORK_TIME}
                      max={MAX_WORK_TIME}
                      onChange={(e) =>
                        onScheduleDetailChange(index, "startTime", e.target.value)
                      }
                    />
                    <span>to</span>
                    <input
                      type="time"
                      value={day.endTime}
                      min={MIN_WORK_TIME}
                      max={MAX_WORK_TIME}
                      onChange={(e) =>
                        onScheduleDetailChange(index, "endTime", e.target.value)
                      }
                    />
                </div>
                <label className="checkbox">
                  <input
                    type="checkbox"
                    checked={day.isAvailable}
                    onChange={(e) =>
                      onScheduleDetailChange(index, "isAvailable", e.target.checked)
                    }
                  />
                  Available
                </label>
              </div>
            );
            })}
          </div>
          <p className="time-range-note">
            Allowed time range: {MIN_WORK_TIME} - {MAX_WORK_TIME}. Sundays are excluded automatically.
          </p>

          <div className="form-actions">
            <button type="button" className="btn btn-secondary" onClick={onCancel}>
              Cancel
            </button>
            <button type="submit" className="btn btn-primary">
              {editingSchedule ? "Update Schedule" : "Create Schedule"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

const ScheduleDetailModal = ({ schedule, onClose }) => {
  const [expandedDay, setExpandedDay] = useState(0);

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h2>Schedule Details</h2>
          <button className="btn-close" onClick={onClose}>
            <X size={24} />
          </button>
        </div>

        <div className="detail-content">
          <div className="detail-info">
            <p>
              <strong>Nutritionist:</strong> {schedule.nutritionistId?.email || "Nutritionist"}
            </p>
            <p>
              <strong>Status:</strong>{" "}
              <span className={`status-badge status-${schedule.status}`}>
                {schedule.status}
              </span>
            </p>
            <p>
              <strong>Total Work Days:</strong> {schedule.workDays?.length || 0}
            </p>
          </div>

          <div className="section-title">Work Days</div>
          <div className="schedule-accordion">
            {(schedule.workDays || []).map((day, index) => (
              <div key={day.date} className="accordion-item">
                <button
                  className="accordion-header"
                  onClick={() => setExpandedDay(expandedDay === index ? -1 : index)}
                >
                  <span>{day.date}</span>
                  <div className="day-status">
                    <span className="time">
                      {day.startTime} - {day.endTime}
                    </span>
                    {day.isAvailable && <span className="badge-available">Available</span>}
                    <ChevronDown
                      size={20}
                      className={expandedDay === index ? "rotated" : ""}
                    />
                  </div>
                </button>
                {expandedDay === index && (
                  <div className="accordion-content">
                    <p>
                      <strong>Hours:</strong> {day.startTime} - {day.endTime}
                    </p>
                    <p>
                      <strong>Status:</strong>{" "}
                      {day.isAvailable ? "Available" : "Not Available"}
                    </p>
                  </div>
                )}
              </div>
            ))}
          </div>

          {schedule.specialDays?.length > 0 && (
            <div className="special-dates-section">
              <div className="section-title">Special Days</div>
              <div className="special-dates-list">
                {schedule.specialDays.map((date, index) => (
                  <div key={index} className="special-date-item">
                    <span>{new Date(date.date).toLocaleDateString()}</span>
                    <span className="type-badge">{date.type}</span>
                    {date.reason && <span className="reason">{date.reason}</span>}
                  </div>
                ))}
              </div>
            </div>
          )}

          <button className="btn btn-secondary btn-block" onClick={onClose}>
            Close
          </button>
        </div>
      </div>
    </div>
  );
};

export default NutritionistScheduleManagement;
