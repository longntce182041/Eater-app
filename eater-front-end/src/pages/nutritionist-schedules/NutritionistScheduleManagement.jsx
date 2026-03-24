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

// Generate next 7 days starting from tomorrow
const generateNextDays = () => {
  const dates = [];
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);

  for (let i = 0; i < 7; i++) {
    const date = new Date(tomorrow);
    date.setDate(date.getDate() + i);
    const dateStr = date.toISOString().split("T")[0];
    dates.push({
      date: dateStr,
      startTime: "09:00",
      endTime: "17:00",
      isAvailable: true,
    });
  }
  return dates;
};

const NutritionistScheduleManagement = () => {
  const [schedules, setSchedules] = useState([]);
  const [nutritionists, setNutritionists] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [editingSchedule, setEditingSchedule] = useState(null);
  const [selectedSchedule, setSelectedSchedule] = useState(null);
  const [formData, setFormData] = useState({
    nutritionistId: "",
    workDays: generateNextDays(),
    specialDays: [],
  });

  useEffect(() => {
    fetchSchedules();
    fetchNutritionists();
  }, []);

  const fetchNutritionists = async () => {
    try {
      const data = await getAllNutritionists();
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
      if (!Array.isArray(formData.workDays) || formData.workDays.length === 0) {
        setError("Work days are required");
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

      await createNutritionistSchedule(formData);
      fetchSchedules();
      resetForm();
      setShowForm(false);
    } catch (err) {
      setError(err.message || "Failed to create schedule");
      console.error("Error creating schedule:", err);
    }
  };

  const handleUpdateSchedule = async (e) => {
    e.preventDefault();
    if (!editingSchedule) return;

    try {
      await updateNutritionistSchedule(editingSchedule._id, formData);
      fetchSchedules();
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
      setSelectedSchedule(null);
    } catch (err) {
      setError(err.message || "Failed to delete schedule");
      console.error("Error deleting schedule:", err);
    }
  };

  const resetForm = () => {
    setFormData({
      nutritionistId: "",
      workDays: generateNextDays(),
      specialDays: [],
    });
    setEditingSchedule(null);
  };

  const handleEditClick = (schedule) => {
    setEditingSchedule(schedule);
    setFormData({
      nutritionistId: schedule.nutritionistId._id,
      workDays: schedule.workDays,
      specialDays: schedule.specialDays,
    });
    setShowForm(true);
  };

  const handleScheduleDetailChange = (dayIndex, field, value) => {
    const updatedWorkDays = [...formData.workDays];
    updatedWorkDays[dayIndex][field] = value;
    setFormData({ ...formData, workDays: updatedWorkDays });
  };

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
        ) : (
          schedules.map((schedule) => (
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
              <label htmlFor="nutritionistId">Nutritionist *</label>
              <select
                id="nutritionistId"
                value={formData.nutritionistId}
                onChange={(e) =>
                  setFormData({ ...formData, nutritionistId: e.target.value })
                }
                required
              >
                <option value="">-- Select a Nutritionist --</option>
                {nutritionists.map((nut) => (
                  <option key={nut.id} value={nut.id}>
                    {nut.fullName} ({nut.email})
                  </option>
                ))}
              </select>
            </div>
          )}

          <div className="section-title">Work Days Schedule</div>
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
                      onChange={(e) =>
                        onScheduleDetailChange(index, "startTime", e.target.value)
                      }
                    />
                    <span>to</span>
                    <input
                      type="time"
                      value={day.endTime}
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
