import React, { useState, useEffect } from "react";
import {
  CheckCircle,
  XCircle,
  Clock,
  AlertCircle,
  X,
} from "lucide-react";
import {
  getAllChangeRequests,
  approveChangeRequest,
  rejectChangeRequest,
} from "@/services/nutritionistScheduleApi";
import "./ScheduleChangeRequests.css";

const ScheduleChangeRequests = () => {
  const [requests, setRequests] = useState([]);
  const [filteredRequests, setFilteredRequests] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [statusFilter, setStatusFilter] = useState("pending");
  const [selectedRequest, setSelectedRequest] = useState(null);
  const [reviewingRequest, setReviewingRequest] = useState(null);
  const [adminNotes, setAdminNotes] = useState("");

  useEffect(() => {
    fetchChangeRequests();
  }, [statusFilter]);

  const fetchChangeRequests = async () => {
    try {
      setLoading(true);
      const data = await getAllChangeRequests(statusFilter);
      setRequests(data || []);
      setFilteredRequests(data || []);
      setError(null);
    } catch (err) {
      setError(err.message || "Failed to load change requests");
      console.error("Error fetching requests:", err);
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (requestId) => {
    try {
      await approveChangeRequest(requestId, { adminNotes });
      fetchChangeRequests();
      setReviewingRequest(null);
      setAdminNotes("");
    } catch (err) {
      setError(err.message || "Failed to approve request");
      console.error("Error approving request:", err);
    }
  };

  const handleReject = async (requestId) => {
    try {
      await rejectChangeRequest(requestId, { adminNotes });
      fetchChangeRequests();
      setReviewingRequest(null);
      setAdminNotes("");
    } catch (err) {
      setError(err.message || "Failed to reject request");
      console.error("Error rejecting request:", err);
    }
  };

  if (loading) {
    return <div className="loading">Loading schedule change requests...</div>;
  }

  const pendingCount = requests.filter((r) => r.status === "pending").length;
  const approvedCount = requests.filter((r) => r.status === "approved").length;
  const rejectedCount = requests.filter((r) => r.status === "rejected").length;

  return (
    <div className="schedule-change-requests">
      <div className="page-header">
        <div>
          <h1>Nutritionist Schedule Change Requests</h1>
          <p className="subtitle">Review and manage schedule change requests from nutritionists</p>
        </div>
        <div className="stats">
          <div className="stat pending">
            <Clock size={20} />
            <div>
              <p className="label">Pending</p>
              <p className="count">{pendingCount}</p>
            </div>
          </div>
          <div className="stat approved">
            <CheckCircle size={20} />
            <div>
              <p className="label">Approved</p>
              <p className="count">{approvedCount}</p>
            </div>
          </div>
          <div className="stat rejected">
            <XCircle size={20} />
            <div>
              <p className="label">Rejected</p>
              <p className="count">{rejectedCount}</p>
            </div>
          </div>
        </div>
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

      <div className="filter-section">
        <button
          className={`filter-btn ${statusFilter === "pending" ? "active" : ""}`}
          onClick={() => setStatusFilter("pending")}
        >
          Pending ({pendingCount})
        </button>
        <button
          className={`filter-btn ${statusFilter === "approved" ? "active" : ""}`}
          onClick={() => setStatusFilter("approved")}
        >
          Approved ({approvedCount})
        </button>
        <button
          className={`filter-btn ${statusFilter === "rejected" ? "active" : ""}`}
          onClick={() => setStatusFilter("rejected")}
        >
          Rejected ({rejectedCount})
        </button>
        <button
          className={`filter-btn ${statusFilter === "" ? "active" : ""}`}
          onClick={() => setStatusFilter("")}
        >
          All
        </button>
      </div>

      {filteredRequests.length === 0 ? (
        <div className="empty-state">
          <Clock size={48} />
          <p>No {statusFilter ? statusFilter : ""} requests</p>
        </div>
      ) : (
        <div className="requests-list">
          {filteredRequests.map((request) => (
            <RequestCard
              key={request._id}
              request={request}
              onView={() => setSelectedRequest(request)}
              onReview={() => setReviewingRequest(request)}
            />
          ))}
        </div>
      )}

      {selectedRequest && (
        <RequestDetailModal
          request={selectedRequest}
          onClose={() => setSelectedRequest(null)}
          onReview={() => {
            setReviewingRequest(selectedRequest);
            setSelectedRequest(null);
          }}
        />
      )}

      {reviewingRequest && (
        <ReviewRequestModal
          request={reviewingRequest}
          adminNotes={adminNotes}
          setAdminNotes={setAdminNotes}
          onApprove={() => handleApprove(reviewingRequest._id)}
          onReject={() => handleReject(reviewingRequest._id)}
          onClose={() => {
            setReviewingRequest(null);
            setAdminNotes("");
          }}
        />
      )}
    </div>
  );
};

const RequestCard = ({ request, onView, onReview }) => {
  const statusIcons = {
    pending: <Clock size={18} />,
    approved: <CheckCircle size={18} />,
    rejected: <XCircle size={18} />,
  };

  const getDateRange = (request) => {
    if (!request.affectedDates) return "";
    const start = new Date(request.affectedDates.startDate).toLocaleDateString();
    const end = request.affectedDates.endDate
      ? ` - ${new Date(request.affectedDates.endDate).toLocaleDateString()}`
      : "";
    return start + end;
  };

  return (
    <div className={`request-card status-${request.status}`}>
      <div className="card-header">
        <div className="status-indicator">
          {statusIcons[request.status]}
        </div>
        <div className="header-info">
          <h3>{request.nutritionistId?.fullName}</h3>
          <p className="subtitle">{request.userId?.email}</p>
        </div>
        <span className={`status-badge status-${request.status}`}>
          {request.status.toUpperCase()}
        </span>
      </div>

      <div className="card-body">
        <div className="info-grid">
          <div className="info-item">
            <span className="label">Request Type</span>
            <span className="value">
              {request.requestType.replace(/_/g, " ").toUpperCase()}
            </span>
          </div>
          <div className="info-item">
            <span className="label">Date Range</span>
            <span className="value">{getDateRange(request)}</span>
          </div>
          <div className="info-item">
            <span className="label">Reason</span>
            <span className="value highlight">{request.reason}</span>
          </div>
        </div>

        {request.proposedChanges && Object.keys(request.proposedChanges).length > 0 && (
          <div className="proposed-section">
            <p className="section-title">Proposed Changes</p>
            <div className="changes-list">
              {request.proposedChanges.dayOfWeek && (
                <p>
                  <strong>Day:</strong> {request.proposedChanges.dayOfWeek}
                </p>
              )}
              {request.proposedChanges.startTime && (
                <p>
                  <strong>Time:</strong> {request.proposedChanges.startTime} -{" "}
                  {request.proposedChanges.endTime}
                </p>
              )}
            </div>
          </div>
        )}

        {request.adminNotes && (
          <div className="notes-section">
            <p className="section-title">Admin Notes</p>
            <p className="notes-text">{request.adminNotes}</p>
          </div>
        )}
      </div>

      <div className="card-footer">
        <span className="date">
          {new Date(request.createdAt).toLocaleDateString()}
        </span>
        <div className="actions">
          <button className="btn btn-text" onClick={onView}>
            View Details
          </button>
          {request.status === "pending" && (
            <button className="btn btn-primary" onClick={onReview}>
              Review
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

const RequestDetailModal = ({ request, onClose, onReview }) => {
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h2>Schedule Change Request Details</h2>
          <button className="btn-close" onClick={onClose}>
            <X size={24} />
          </button>
        </div>

        <div className="modal-body">
          <div className="detail-section">
            <h3>Nutritionist Information</h3>
            <p>
              <strong>Name:</strong> {request.nutritionistId?.fullName}
            </p>
            <p>
              <strong>Email:</strong> {request.userId?.email}
            </p>
          </div>

          <div className="detail-section">
            <h3>Request Details</h3>
            <p>
              <strong>Type:</strong>{" "}
              {request.requestType.replace(/_/g, " ").toUpperCase()}
            </p>
            <p>
              <strong>Status:</strong>{" "}
              <span className={`status-badge status-${request.status}`}>
                {request.status.toUpperCase()}
              </span>
            </p>
            <p>
              <strong>Reason:</strong>
            </p>
            <p className="reason-text">{request.reason}</p>
          </div>

          {request.affectedDates && (
            <div className="detail-section">
              <h3>Affected Dates</h3>
              <p>
                <strong>Start Date:</strong>{" "}
                {new Date(request.affectedDates.startDate).toLocaleDateString(
                  "en-US",
                  {
                    year: "numeric",
                    month: "long",
                    day: "numeric",
                  }
                )}
              </p>
              {request.affectedDates.endDate && (
                <p>
                  <strong>End Date:</strong>{" "}
                  {new Date(request.affectedDates.endDate).toLocaleDateString(
                    "en-US",
                    {
                      year: "numeric",
                      month: "long",
                      day: "numeric",
                    }
                  )}
                </p>
              )}
            </div>
          )}

          {request.proposedChanges &&
            Object.keys(request.proposedChanges).length > 0 && (
              <div className="detail-section">
                <h3>Proposed Changes</h3>
                {request.proposedChanges.dayOfWeek && (
                  <p>
                    <strong>Day of Week:</strong>{" "}
                    {request.proposedChanges.dayOfWeek}
                  </p>
                )}
                {request.proposedChanges.startTime && (
                  <p>
                    <strong>Proposed Time:</strong>{" "}
                    {request.proposedChanges.startTime} -{" "}
                    {request.proposedChanges.endTime}
                  </p>
                )}
              </div>
            )}

          {request.adminNotes && (
            <div className="detail-section">
              <h3>Admin Notes</h3>
              <p className="notes-text">{request.adminNotes}</p>
            </div>
          )}

          <div className="modal-footer">
            <button className="btn btn-secondary" onClick={onClose}>
              Close
            </button>
            {request.status === "pending" && (
              <button className="btn btn-primary" onClick={onReview}>
                Review Request
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

const ReviewRequestModal = ({
  request,
  adminNotes,
  setAdminNotes,
  onApprove,
  onReject,
  onClose,
}) => {
  const [approving, setApproving] = useState(false);
  const [rejecting, setRejecting] = useState(false);

  const handleApprove = async () => {
    setApproving(true);
    try {
      await onApprove();
    } finally {
      setApproving(false);
    }
  };

  const handleReject = async () => {
    setRejecting(true);
    try {
      await onReject();
    } finally {
      setRejecting(false);
    }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content modal-large" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h2>Review Schedule Change Request</h2>
          <button className="btn-close" onClick={onClose}>
            <X size={24} />
          </button>
        </div>

        <div className="modal-body">
          <div className="review-info">
            <h3>{request.nutritionistId?.fullName}</h3>
            <p className="subtitle">{request.userId?.email}</p>

            <div className="request-summary">
              <div className="summary-item">
                <span className="label">Type</span>
                <span className="value">
                  {request.requestType.replace(/_/g, " ").toUpperCase()}
                </span>
              </div>
              <div className="summary-item">
                <span className="label">Reason</span>
                <span className="value">{request.reason}</span>
              </div>
            </div>
          </div>

          <div className="review-form">
            <label htmlFor="adminNotes">Your Admin Notes (Optional)</label>
            <textarea
              id="adminNotes"
              value={adminNotes}
              onChange={(e) => setAdminNotes(e.target.value)}
              placeholder="Provide any feedback or explanation for your decision..."
              rows="6"
            ></textarea>
          </div>

          <div className="modal-footer review-actions">
            <button
              className="btn btn-secondary"
              onClick={onClose}
              disabled={approving || rejecting}
            >
              Cancel
            </button>
            <button
              className="btn btn-danger"
              onClick={handleReject}
              disabled={approving || rejecting}
            >
              <XCircle size={16} /> {rejecting ? "Rejecting..." : "Reject Request"}
            </button>
            <button
              className="btn btn-success"
              onClick={handleApprove}
              disabled={approving || rejecting}
            >
              <CheckCircle size={16} /> {approving ? "Approving..." : "Approve Request"}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ScheduleChangeRequests;
