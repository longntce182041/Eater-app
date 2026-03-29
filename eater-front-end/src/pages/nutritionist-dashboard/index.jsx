import React, { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  CalendarDays,
  Clock3,
  UserCog,
  MessageCircle,
  ClipboardList,
  ArrowRight,
} from "lucide-react";

import { getMySchedule, getNutritionistChangeRequests } from "../../services/nutritionistScheduleApi";
import { nutritionistsApi } from "../../services/nutritionistsApi";
import { chatApi } from "../../services/chatApi";

const normalizeDateOnly = (value) => {
  if (!value) return null;

  if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return value;
  }

  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return null;
  }

  const year = parsed.getFullYear();
  const month = String(parsed.getMonth() + 1).padStart(2, "0");
  const day = String(parsed.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
};

const toDateLabel = (dateKey) => {
  if (!dateKey) return "N/A";
  const parsed = new Date(`${dateKey}T00:00:00`);
  if (Number.isNaN(parsed.getTime())) return "N/A";

  return parsed.toLocaleDateString("en-US", {
    weekday: "short",
    month: "short",
    day: "numeric",
  });
};

const toTimeRangeLabel = (workDay) => {
  if (!workDay) return "No shift";
  if (!workDay.isAvailable) return "Unavailable";
  if (!workDay.startTime || !workDay.endTime) return "Shift configured";
  return `${workDay.startTime} - ${workDay.endTime}`;
};

const extractNutritionistId = (schedule) => {
  if (!schedule?.nutritionistId) return null;
  return typeof schedule.nutritionistId === "object"
    ? schedule.nutritionistId?._id
    : schedule.nutritionistId;
};

const NutritionistDashboardPage = () => {
  const navigate = useNavigate();

  const [loading, setLoading] = useState(true);
  const [profile, setProfile] = useState(null);
  const [schedule, setSchedule] = useState(null);
  const [requestStats, setRequestStats] = useState({
    total: 0,
    pending: 0,
  });
  const [contactsCount, setContactsCount] = useState(0);

  useEffect(() => {
    let mounted = true;

    const fetchDashboardData = async () => {
      setLoading(true);

      try {
        const [profileResult, scheduleResult, contactsResult] = await Promise.allSettled([
          nutritionistsApi.getMyProfessionalProfile(),
          getMySchedule(),
          chatApi.getContacts(),
        ]);

        if (!mounted) return;

        const profileData =
          profileResult.status === "fulfilled"
            ? profileResult.value?.data?.data || null
            : null;

        const scheduleData =
          scheduleResult.status === "fulfilled" ? scheduleResult.value || null : null;

        const contacts =
          contactsResult.status === "fulfilled"
            ? contactsResult.value?.data?.data || contactsResult.value?.data || []
            : [];

        setProfile(profileData);
        setSchedule(scheduleData);
        setContactsCount(Array.isArray(contacts) ? contacts.length : 0);

        const nutritionistId = extractNutritionistId(scheduleData);

        if (nutritionistId) {
          try {
            const requests = await getNutritionistChangeRequests(nutritionistId);
            if (!mounted) return;

            const normalized = Array.isArray(requests) ? requests : [];
            const pending = normalized.filter(
              (item) => (item?.status || "").toLowerCase() === "pending"
            ).length;

            setRequestStats({
              total: normalized.length,
              pending,
            });
          } catch {
            if (!mounted) return;
            setRequestStats({ total: 0, pending: 0 });
          }
        } else {
          setRequestStats({ total: 0, pending: 0 });
        }
      } finally {
        if (mounted) {
          setLoading(false);
        }
      }
    };

    fetchDashboardData();

    return () => {
      mounted = false;
    };
  }, []);

  const workDays = useMemo(() => {
    const list = Array.isArray(schedule?.workDays) ? schedule.workDays : [];
    return list
      .map((item) => ({
        ...item,
        normalizedDate: normalizeDateOnly(item?.date),
      }))
      .filter((item) => item.normalizedDate)
      .sort((a, b) => a.normalizedDate.localeCompare(b.normalizedDate));
  }, [schedule]);

  const todayKey = useMemo(() => normalizeDateOnly(new Date()), []);

  const upcomingShift = useMemo(() => {
    if (!todayKey || workDays.length === 0) return null;
    return workDays.find((item) => item.normalizedDate >= todayKey) || null;
  }, [todayKey, workDays]);

  const thisMonthWorkDays = useMemo(() => {
    if (workDays.length === 0) return 0;

    const now = new Date();
    const monthPrefix = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}`;

    return workDays.filter((day) => day.normalizedDate.startsWith(monthPrefix)).length;
  }, [workDays]);

  const profileCompleted = Boolean(
    profile?.fullName && profile?.specialization && Number.isFinite(Number(profile?.experience))
  );

  const statCards = [
    {
      title: "Workdays This Month",
      value: loading ? "..." : thisMonthWorkDays,
      icon: <CalendarDays size={22} />,
      color: "#30a5ff",
    },
    {
      title: "Pending Change Requests",
      value: loading ? "..." : requestStats.pending,
      icon: <Clock3 size={22} />,
      color: "#f0ad4e",
    },
    {
      title: "Chat Contacts",
      value: loading ? "..." : contactsCount,
      icon: <MessageCircle size={22} />,
      color: "#1ebfae",
    },
    {
      title: "Profile Status",
      value: loading ? "..." : profileCompleted ? "Completed" : "Needs Update",
      icon: <UserCog size={22} />,
      color: profileCompleted ? "#28a745" : "#dc3545",
    },
  ];

  const quickActions = [
    {
      title: "View My Schedule",
      description: "Open your calendar and assigned work slots.",
      path: "/nutritionist/my-schedule?tab=schedule",
      color: "#30a5ff",
    },
    {
      title: "Review Change Requests",
      description: `Track your submitted requests (${requestStats.total} total).`,
      path: "/nutritionist/my-schedule?tab=requests",
      color: "#f0ad4e",
    },
    {
      title: "Open Consultations",
      description: "Start diagnosis and assign meal plans to patients.",
      path: "/consultations",
      color: "#1ebfae",
    },
    {
      title: "Go To Live Chat",
      description: "Chat directly with your active patient contacts.",
      path: "/chat",
      color: "#8e44ad",
    },
    {
      title: "Update Professional Profile",
      description: "Maintain your specialization and certificates.",
      path: "/nutritionist/profile",
      color: "#34495e",
    },
  ];

  return (
    <div>
      <h2 style={{ fontSize: "24px", marginBottom: "8px", color: "#30a5ff", fontWeight: 600 }}>
        Nutritionist Dashboard
      </h2>
      <p style={{ marginTop: 0, marginBottom: "22px", color: "#666" }}>
        Your daily overview for schedule, consultations, and communication.
      </p>

      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))", gap: "14px", marginBottom: "22px" }}>
        {statCards.map((card) => (
          <div
            key={card.title}
            style={{
              background: "#fff",
              borderRadius: "10px",
              borderTop: `4px solid ${card.color}`,
              boxShadow: "0 1px 2px rgba(0,0,0,0.08)",
              padding: "16px",
            }}
          >
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", color: card.color }}>
              <span style={{ fontSize: "13px", fontWeight: 700, textTransform: "uppercase" }}>{card.title}</span>
              {card.icon}
            </div>
            <div style={{ marginTop: "10px", fontSize: "24px", fontWeight: 700, color: "#333" }}>
              {card.value}
            </div>
          </div>
        ))}
      </div>

      <div style={{ background: "#fff", borderRadius: "10px", boxShadow: "0 1px 2px rgba(0,0,0,0.08)", padding: "18px", marginBottom: "20px" }}>
        <h3 style={{ marginTop: 0, marginBottom: "14px", color: "#4a4a4a" }}>
          <ClipboardList size={18} style={{ verticalAlign: "middle", marginRight: "8px" }} />
          Next Shift Snapshot
        </h3>

        {!schedule && !loading && (
          <p style={{ margin: 0, color: "#777" }}>
            You do not have an assigned schedule yet. Please contact admin.
          </p>
        )}

        {(schedule || loading) && (
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))", gap: "10px" }}>
            <SnapshotItem
              label="Schedule Status"
              value={loading ? "..." : (schedule?.status || "not_assigned").replace(/_/g, " ")}
            />
            <SnapshotItem
              label="Next Workday"
              value={loading ? "..." : upcomingShift ? toDateLabel(upcomingShift.normalizedDate) : "No upcoming shift"}
            />
            <SnapshotItem
              label="Shift Time"
              value={loading ? "..." : toTimeRangeLabel(upcomingShift)}
            />
          </div>
        )}
      </div>

      <div style={{ background: "#fff", borderRadius: "10px", boxShadow: "0 1px 2px rgba(0,0,0,0.08)", padding: "18px" }}>
        <h3 style={{ marginTop: 0, marginBottom: "14px", color: "#4a4a4a" }}>Quick Actions</h3>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(260px, 1fr))", gap: "12px" }}>
          {quickActions.map((action) => (
            <button
              key={action.title}
              type="button"
              onClick={() => navigate(action.path)}
              style={{
                textAlign: "left",
                border: `1px solid ${action.color}`,
                background: "#fff",
                borderRadius: "8px",
                padding: "14px",
                cursor: "pointer",
              }}
            >
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "6px" }}>
                <strong style={{ color: action.color }}>{action.title}</strong>
                <ArrowRight size={16} color={action.color} />
              </div>
              <div style={{ color: "#666", fontSize: "13px" }}>{action.description}</div>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};

const SnapshotItem = ({ label, value }) => {
  return (
    <div
      style={{
        background: "#f9fbfd",
        borderRadius: "8px",
        border: "1px solid #edf2f7",
        padding: "12px",
      }}
    >
      <div style={{ fontSize: "12px", textTransform: "uppercase", color: "#8a8a8a", marginBottom: "4px" }}>
        {label}
      </div>
      <div style={{ fontSize: "16px", fontWeight: 600, color: "#333" }}>{value}</div>
    </div>
  );
};

export default NutritionistDashboardPage;
