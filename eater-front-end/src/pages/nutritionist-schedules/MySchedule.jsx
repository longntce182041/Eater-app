import React, { useState, useEffect } from "react";
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
  return (
    <div className="schedule-view">
      <div className="schedule-info-box">
        <div className="info-item">
          <Clock size={18} />
          <div>
            <p className="label">Total Work Days</p>
            <p className="value">{schedule.workDays?.length || 0}</p>
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

      <div className="section-title">Work Days</div>
      <div className="weekly-schedule">
        {(schedule.workDays || []).map((day) => (
          <div key={day.date} className="day-card">
            <div className="day-name">{day.date}</div>
            <div className="day-content">
              {day.isAvailable ? (
                <>
                  <div className="time">
                    <Clock size={16} />
                    <span>
                      {day.startTime} - {day.endTime}
                    </span>
                  </div>
                  <span className="available-badge">Available</span>
                </>
              ) : (
                <span className="not-available">Not Available</span>
              )}
            </div>
          </div>
        ))}
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

  const [formData, setFormData] = useState({
    scheduleId: schedule._id,
    requestType: "take_day_off",
    reason: "",
    affectedDates: {
      startDate: minDate,
      endDate: null,
    },
    proposedChanges: {
      date: "",
      startTime: "",
      endTime: "",
    },
  });

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setLoading(true);
      await requestScheduleChange(formData);
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
              <option value="take_day_off">Take Day Off</option>
              <option value="vacation">Vacation</option>
              <option value="modify_hours">Modify Working Hours</option>
              <option value="special_request">Special Request</option>
            </select>
          </div>

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
                  <option value="">Select a date</option>
                  {(schedule.workDays || []).map((day) => (
                    <option key={day.date} value={day.date}>
                      {day.date}
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
