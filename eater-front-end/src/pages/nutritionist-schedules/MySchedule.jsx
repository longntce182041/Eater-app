import React, { useState, useEffect, useMemo } from "react";
import { useSearchParams } from "react-router-dom";
import {
  Calendar,
  Clock,
  AlertCircle,
  Send,
  CheckCircle,
  Clock3,
  X,
} from "lucide-react";
import {
  getMySchedule,
  requestScheduleChange,
  getNutritionistChangeRequests,
} from "@/services/nutritionistScheduleApi";
import "./MySchedule.css";

const WEEKDAY_LABELS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
const MIN_WORK_TIME = "09:00";
const MAX_WORK_TIME = "17:00";

const toDateKey = (date) => {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
};

const parseDateKey = (dateKey) => {
  if (!dateKey) return null;
  const parsed = new Date(`${dateKey}T00:00:00`);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
};

const addDaysToDateString = (dateStr, days) => {
  if (!dateStr) return null;
  const parsed = new Date(`${dateStr}T00:00:00`);
  if (Number.isNaN(parsed.getTime())) return null;
  parsed.setDate(parsed.getDate() + days);
  const year = parsed.getFullYear();
  const month = String(parsed.getMonth() + 1).padStart(2, "0");
  const day = String(parsed.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
};

const normalizeDateKey = (value) => {
  if (!value) return null;
  if (/^\d{4}-\d{2}-\d{2}$/.test(value)) return value;
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) return null;
  return toDateKey(parsed);
};

const MySchedule = () => {
  const [searchParams, setSearchParams] = useSearchParams();
  const initialTab = searchParams.get("tab") === "requests" ? "requests" : "schedule";
  const [schedule, setSchedule] = useState(null);
  const [changeRequests, setChangeRequests] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showRequestForm, setShowRequestForm] = useState(false);
  const [activeTab, setActiveTab] = useState(initialTab); // schedule or requests

  useEffect(() => {
    const tab = searchParams.get("tab") === "requests" ? "requests" : "schedule";
    setActiveTab(tab);
  }, [searchParams]);

  const handleTabChange = (tab) => {
    setActiveTab(tab);
    setSearchParams({ tab });
  };

  useEffect(() => {
    fetchScheduleAndRequests();
  }, []);

  const fetchScheduleAndRequests = async () => {
    try {
      setLoading(true);
      const schedule = await getMySchedule();
      setSchedule(schedule);
      // Get change requests if we have a schedule with nutritionistId
      if (schedule && schedule.nutritionistId) {
        const nutritionistId =
          typeof schedule.nutritionistId === "object"
            ? schedule.nutritionistId._id
            : schedule.nutritionistId;
        const requests = await getNutritionistChangeRequests(nutritionistId);
        setChangeRequests(requests || []);
      }
      setError(null);
    } catch (err) {
      setError(err.message || "Failed to load schedule");
      console.error("Error fetching schedule:", err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="loading">Loading your schedule...</div>;
  }

  if (!schedule) {
    return (
      <div className="no-schedule">
        <AlertCircle size={48} />
        <h2>No Schedule Assigned</h2>
        <p>You don't have a work schedule yet. Please contact your administrator.</p>
      </div>
    );
  }

  return (
    <div className="my-schedule">
      <div className="schedule-header">
        <div>
          <h1>My Work Schedule</h1>
          <p className="subtitle">View and manage your work schedule</p>
        </div>
        <button
          className="btn btn-primary"
          onClick={() => setShowRequestForm(true)}
        >
          <Calendar size={18} /> Request Schedule Change
        </button>
      </div>

      {error && (
        <div className="alert alert-error">
          <AlertCircle size={20} />
          <span>{error}</span>
        </div>
      )}

      <div className="tabs">
        <button
          className={`tab ${activeTab === "schedule" ? "active" : ""}`}
          onClick={() => handleTabChange("schedule")}
        >
          My Schedule
        </button>
        <button
          className={`tab ${activeTab === "requests" ? "active" : ""}`}
          onClick={() => handleTabChange("requests")}
        >
          Change Requests ({changeRequests.length})
        </button>
      </div>

      {activeTab === "schedule" && (
        <ScheduleView schedule={schedule} />
      )}

      {activeTab === "requests" && (
        <ChangeRequestsList requests={changeRequests} />
      )}

      {showRequestForm && (
        <ChangeRequestForm
          schedule={schedule}
          onClose={() => setShowRequestForm(false)}
          onSuccess={() => {
            setShowRequestForm(false);
            fetchScheduleAndRequests();
          }}
        />
      )}
    </div>
  );
};

const ScheduleView = ({ schedule }) => {
  const [currentMonth, setCurrentMonth] = useState(() => {
    const firstDate = schedule?.workDays?.[0]?.date || schedule?.specialDays?.[0]?.date;
    const parsed = parseDateKey(firstDate);
    const base = parsed || new Date();
    return new Date(base.getFullYear(), base.getMonth(), 1);
  });

  const workDaysMap = useMemo(() => {
    const map = new Map();
    (schedule.workDays || []).forEach((day) => {
      if (day?.date) map.set(day.date, day);
    });
    return map;
  }, [schedule.workDays]);

  const specialDaysMap = useMemo(() => {
    const map = new Map();
    (schedule.specialDays || []).forEach((day) => {
      if (day?.date && !map.has(day.date)) map.set(day.date, day);
    });
    return map;
  }, [schedule.specialDays]);

  const monthData = useMemo(() => {
    const year = currentMonth.getFullYear();
    const month = currentMonth.getMonth();
    const start = new Date(year, month, 1);
    const daysInMonth = new Date(year, month + 1, 0).getDate();
    const startOffset = (start.getDay() + 6) % 7;

    const days = [];
    for (let i = 0; i < startOffset; i += 1) {
      days.push(null);
    }
    for (let day = 1; day <= daysInMonth; day += 1) {
      days.push(new Date(year, month, day));
    }

    const monthPrefix = `${year}-${String(month + 1).padStart(2, "0")}`;
    const monthWorkDays = (schedule.workDays || []).filter((d) =>
      String(d?.date || "").startsWith(monthPrefix)
    ).length;
    const monthSpecialDays = (schedule.specialDays || []).filter((d) =>
      String(d?.date || "").startsWith(monthPrefix)
    ).length;

    return { days, monthWorkDays, monthSpecialDays };
  }, [currentMonth, schedule.workDays, schedule.specialDays]);

  const goToPrevMonth = () => {
    setCurrentMonth(
      (prev) => new Date(prev.getFullYear(), prev.getMonth() - 1, 1)
    );
  };

  const goToNextMonth = () => {
    setCurrentMonth(
      (prev) => new Date(prev.getFullYear(), prev.getMonth() + 1, 1)
    );
  };

  const monthLabel = currentMonth.toLocaleDateString("en-US", {
    month: "long",
    year: "numeric",
  });

  const todayKey = toDateKey(new Date());

  return (
    <div className="schedule-view">
      <div className="schedule-info-box">
        <div className="info-item">
          <Clock size={18} />
          <div>
            <p className="label">Work Days This Month</p>
            <p className="value">{monthData.monthWorkDays}</p>
          </div>
        </div>
        <div className="info-item">
          <Calendar size={18} />
          <div>
            <p className="label">Special Days This Month</p>
            <p className="value">{monthData.monthSpecialDays}</p>
          </div>
        </div>
        <div className="info-item">
          <AlertCircle size={18} />
          <div>
            <p className="label">Status</p>
            <p className={`value status-${schedule.status}`}>
              {schedule.status.replace("_", " ").toUpperCase()}
            </p>
          </div>
        </div>
      </div>

      <div className="calendar-month-header">
        <button className="month-nav-btn" onClick={goToPrevMonth}>
          Previous
        </button>
        <h3>{monthLabel}</h3>
        <button className="month-nav-btn" onClick={goToNextMonth}>
          Next
        </button>
      </div>

      <div className="month-calendar-grid">
        {WEEKDAY_LABELS.map((label) => (
          <div key={label} className="weekday-header-cell">
            {label}
          </div>
        ))}

        {monthData.days.map((dateObj, index) => {
          if (!dateObj) {
            return <div key={`empty-${index}`} className="calendar-day-cell empty" />;
          }

          const dateKey = toDateKey(dateObj);
          const workDay = workDaysMap.get(dateKey);
          const specialDay = specialDaysMap.get(dateKey);
          const isToday = dateKey === todayKey;
          const isScheduled = Boolean(workDay);
          const isSpecial = Boolean(specialDay);

          return (
            <div
              key={dateKey}
              className={`calendar-day-cell ${
                isScheduled ? "scheduled" : ""
              } ${isSpecial ? "special" : ""} ${isToday ? "today" : ""}`.trim()}
            >
              <div className="day-number">{dateObj.getDate()}</div>

              {isScheduled ? (
                <div className="day-schedule-content">
                  {workDay.isAvailable ? (
                    <>
                      <div className="day-time">{workDay.startTime} - {workDay.endTime}</div>
                      <span className="available-badge">Available</span>
                    </>
                  ) : (
                    <span className="not-available">Not Available</span>
                  )}
                </div>
              ) : (
                <div className="day-schedule-content no-shift">No shift</div>
              )}

              {isSpecial && (
                <span className={`special-tag type-${specialDay.type || "off"}`}>
                  {(specialDay.type || "off").replace(/_/g, " ")}
                </span>
              )}
            </div>
          );
        })}
      </div>

      {schedule.specialDays?.length > 0 && (
        <div className="special-dates-section">
          <div className="section-title">Special Days</div>
          <div className="special-dates-list">
            {schedule.specialDays.map((date, index) => (
              <div key={index} className="special-date-card">
                <div className="date">
                  {new Date(date.date).toLocaleDateString("en-US", {
                    month: "short",
                    day: "numeric",
                    year: "numeric",
                  })}
                </div>
                <div className="info">
                  <span className="type-badge">{date.type}</span>
                  {date.reason && <span className="reason">{date.reason}</span>}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

const ChangeRequestsList = ({ requests }) => {
  if (requests.length === 0) {
    return (
      <div className="empty-state">
        <Calendar size={48} />
        <p>No change requests yet</p>
        <p className="subtitle">When you request a schedule change, it will appear here</p>
      </div>
    );
  }

  const pendingRequests = requests.filter((r) => r.status === "pending");
  const approvedRequests = requests.filter((r) => r.status === "approved");
  const rejectedRequests = requests.filter((r) => r.status === "rejected");

  return (
    <div className="change-requests-list">
      {pendingRequests.length > 0 && (
        <RequestSection title="Pending" requests={pendingRequests} />
      )}
      {approvedRequests.length > 0 && (
        <RequestSection title="Approved" requests={approvedRequests} />
      )}
      {rejectedRequests.length > 0 && (
        <RequestSection title="Rejected" requests={rejectedRequests} />
      )}
    </div>
  );
};

const RequestSection = ({ title, requests }) => {
  return (
    <div className="request-section">
      <h3 className="section-title">{title}</h3>
      <div className="requests-grid">
        {requests.map((request) => (
          <div key={request._id} className={`request-card status-${request.status}`}>
            <div className="request-header">
              <div className="status-icon">
                {request.status === "pending" && <Clock3 size={20} />}
                {request.status === "approved" && <CheckCircle size={20} />}
                {request.status === "rejected" && <AlertCircle size={20} />}
              </div>
              <span className="status-label">{request.status.toUpperCase()}</span>
            </div>

            <div className="request-details">
              <p>
                <strong>Type:</strong>{" "}
                {request.requestType.replace(/_/g, " ").toUpperCase()}
              </p>
              <p>
                <strong>Reason:</strong> {request.reason}
              </p>

              {request.affectedDates && (
                <>
                  {request.affectedDates.startDate && (
                    <p>
                      <strong>Start Date:</strong>{" "}
                      {new Date(
                        request.affectedDates.startDate
                      ).toLocaleDateString()}
                    </p>
                  )}
                  {request.affectedDates.endDate && (
                    <p>
                      <strong>End Date:</strong>{" "}
                      {new Date(
                        request.affectedDates.endDate
                      ).toLocaleDateString()}
                    </p>
                  )}
                </>
              )}

              {request.proposedChanges && (
                <div className="proposed-changes">
                  <strong>Proposed Changes:</strong>
                  {request.proposedChanges.date && (
                    <p>Date: {request.proposedChanges.date}</p>
                  )}
                  {request.proposedChanges.startTime && (
                    <p>
                      Time: {request.proposedChanges.startTime} -{" "}
                      {request.proposedChanges.endTime}
                    </p>
                  )}
                  {request.proposedChanges.offHours > 0 && (
                    <p>Hours Off: {request.proposedChanges.offHours} hour(s)</p>
                  )}
                  {request.proposedChanges.offDays > 0 && (
                    <p>Days Off: {request.proposedChanges.offDays} day(s)</p>
                  )}
                </div>
              )}
            </div>

            {request.status !== "pending" && (
              <div className="admin-notes">
                <strong>Admin Notes:</strong>
                <p>{request.adminNotes || "No notes provided"}</p>
              </div>
            )}

            <div className="request-footer">
              <span className="date">
                {new Date(request.createdAt).toLocaleDateString()}
              </span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

const ChangeRequestForm = ({ schedule, onClose, onSuccess }) => {
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  const minDate = tomorrow.toISOString().split("T")[0];

  const modifyHoursAvailableDates = useMemo(
    () =>
      (schedule.workDays || []).reduce((dates, day) => {
        const dateKey = normalizeDateKey(day?.date);
        if (dateKey && dateKey >= minDate) {
          dates.push(dateKey);
        }
        return dates;
      }, []),
    [schedule.workDays, minDate]
  );

  const [formData, setFormData] = useState({
    scheduleId: schedule._id,
    requestType: "vacation",
    reason: "",
    affectedDates: {
      startDate: minDate,
      endDate: null,
    },
    proposedChanges: {
      date: "",
      startTime: "",
      endTime: "",
      offDays: "",
    },
  });

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (formData.requestType !== "modify_hours") return;

    const selectedDate = formData.proposedChanges.date;
    const isSelectedDateValid = modifyHoursAvailableDates.includes(selectedDate);

    if (!isSelectedDateValid) {
      setFormData((prev) => ({
        ...prev,
        proposedChanges: {
          ...prev.proposedChanges,
          date: modifyHoursAvailableDates[0] || "",
        },
      }));
    }
  }, [
    formData.requestType,
    formData.proposedChanges.date,
    modifyHoursAvailableDates,
  ]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setLoading(true);

      const payload = {
        ...formData,
        proposedChanges: {
          ...formData.proposedChanges,
        },
      };

      if (formData.requestType === "vacation") {
        const offDays = Number(formData.proposedChanges.offDays || 0);
        if (offDays > 1) {
          payload.proposedChanges.offDays = offDays;
          payload.affectedDates.endDate = addDaysToDateString(
            formData.affectedDates.startDate,
            offDays - 1
          );
        }
      }

      if (formData.requestType === "modify_hours") {
        const selectedDate = String(formData.proposedChanges.date || "");
        const startTime = String(formData.proposedChanges.startTime || "");
        const endTime = String(formData.proposedChanges.endTime || "");

        if (!selectedDate) {
          setError("Please select a valid future work date.");
          setLoading(false);
          return;
        }

        if (selectedDate < minDate) {
          setError("Modify working hours only supports future dates.");
          setLoading(false);
          return;
        }

        if (!startTime || !endTime) {
          setError("Please select both start time and end time.");
          setLoading(false);
          return;
        }

        if (startTime < MIN_WORK_TIME || startTime > MAX_WORK_TIME) {
          setError(`Start time must be between ${MIN_WORK_TIME} and ${MAX_WORK_TIME}.`);
          setLoading(false);
          return;
        }

        if (endTime < MIN_WORK_TIME || endTime > MAX_WORK_TIME) {
          setError(`End time must be between ${MIN_WORK_TIME} and ${MAX_WORK_TIME}.`);
          setLoading(false);
          return;
        }

        if (startTime >= endTime) {
          setError("End time must be later than start time.");
          setLoading(false);
          return;
        }
      }

      await requestScheduleChange(payload);
      onSuccess();
    } catch (err) {
      setError(err.message || "Failed to submit request");
      console.error("Error submitting request:", err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h2>Request Schedule Change</h2>
          <button className="btn-close" onClick={onClose}>
            <X size={24} />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="change-request-form">
          {error && (
            <div className="alert alert-error">
              <AlertCircle size={16} />
              <span>{error}</span>
            </div>
          )}

          <div className="form-group">
            <label htmlFor="requestType">Request Type *</label>
            <select
              id="requestType"
              value={formData.requestType}
              onChange={(e) =>
                setFormData({ ...formData, requestType: e.target.value })
              }
              required
            >
              <option value="vacation">Vacation</option>
              <option value="modify_hours">Modify Working Hours</option>
              <option value="special_request">Special Request</option>
            </select>
          </div>

          {formData.requestType === "vacation" && (
            <div className="form-group">
              <label htmlFor="vacationDays">Number of Vacation Days</label>
              <input
                id="vacationDays"
                type="number"
                min="1"
                max="31"
                step="1"
                value={formData.proposedChanges.offDays}
                onChange={(e) =>
                  setFormData({
                    ...formData,
                    proposedChanges: {
                      ...formData.proposedChanges,
                      offDays: e.target.value,
                    },
                  })
                }
                placeholder="e.g. 3"
              />
              <small>
                If provided, end date will be auto-calculated from start date.
              </small>
            </div>
          )}

          <div className="form-group">
            <label htmlFor="reason">Reason *</label>
            <textarea
              id="reason"
              value={formData.reason}
              onChange={(e) =>
                setFormData({ ...formData, reason: e.target.value })
              }
              placeholder="Please explain why you need this change..."
              rows="4"
              required
            ></textarea>
          </div>

          <div className="form-group">
            <label htmlFor="startDate">Start Date *</label>
            <input
              id="startDate"
              type="date"
              value={formData.affectedDates.startDate}
              min={minDate}
              onChange={(e) =>
                setFormData({
                  ...formData,
                  affectedDates: {
                    ...formData.affectedDates,
                    startDate: e.target.value,
                  },
                })
              }
              required
            />
          </div>

          {(formData.requestType === "vacation" ||
            formData.requestType === "special_request") && (
            <div className="form-group">
              <label htmlFor="endDate">End Date</label>
              <input
                id="endDate"
                type="date"
                value={formData.affectedDates.endDate || ""}
                min={formData.affectedDates.startDate || minDate}
                onChange={(e) =>
                  setFormData({
                    ...formData,
                    affectedDates: {
                      ...formData.affectedDates,
                      endDate: e.target.value || null,
                    },
                  })
                }
              />
            </div>
          )}

          {formData.requestType === "modify_hours" && (
            <>
              <div className="form-group">
                <label htmlFor="changeDate">Date *</label>
                <select
                  id="changeDate"
                  value={formData.proposedChanges.date}
                  disabled={modifyHoursAvailableDates.length === 0}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      proposedChanges: {
                        ...formData.proposedChanges,
                        date: e.target.value,
                      },
                    })
                  }
                  required
                >
                  <option value="">
                    {modifyHoursAvailableDates.length === 0
                      ? "No future work days available"
                      : "Select a date"}
                  </option>
                  {modifyHoursAvailableDates.map((date) => (
                    <option key={date} value={date}>
                      {date}
                    </option>
                  ))}
                </select>
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label htmlFor="startTime">Start Time *</label>
                  <input
                    id="startTime"
                    type="time"
                    min={MIN_WORK_TIME}
                    max={MAX_WORK_TIME}
                    value={formData.proposedChanges.startTime}
                    onChange={(e) =>
                      setFormData({
                        ...formData,
                        proposedChanges: {
                          ...formData.proposedChanges,
                          startTime: e.target.value,
                        },
                      })
                    }
                    required
                  />
                </div>

                <div className="form-group">
                  <label htmlFor="endTime">End Time *</label>
                  <input
                    id="endTime"
                    type="time"
                    min={MIN_WORK_TIME}
                    max={MAX_WORK_TIME}
                    value={formData.proposedChanges.endTime}
                    onChange={(e) =>
                      setFormData({
                        ...formData,
                        proposedChanges: {
                          ...formData.proposedChanges,
                          endTime: e.target.value,
                        },
                      })
                    }
                    required
                  />
                </div>
              </div>
              <small>Working hours are limited to {MIN_WORK_TIME} - {MAX_WORK_TIME}.</small>
            </>
          )}

          <div className="form-actions">
            <button
              type="button"
              className="btn btn-secondary"
              onClick={onClose}
              disabled={loading}
            >
              Cancel
            </button>
            <button
              type="submit"
              className="btn btn-primary"
              disabled={loading}
            >
              <Send size={16} /> {loading ? "Submitting..." : "Submit Request"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default MySchedule;
