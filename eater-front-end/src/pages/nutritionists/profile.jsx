import React, { useEffect, useMemo, useState } from "react";
import { Save, UserCog } from "lucide-react";
import { toast } from "react-toastify";
import { nutritionistsApi } from "../../services/nutritionistsApi";

const INITIAL_FORM = {
  fullName: "",
  specialization: "",
  experience: "",
  certificationsText: "",
};

const NutritionistProfessionalProfilePage = () => {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [hasProfile, setHasProfile] = useState(false);
  const [formData, setFormData] = useState(INITIAL_FORM);

  const certificationsPreview = useMemo(
    () => formData.certificationsText.split("\n").map((s) => s.trim()).filter(Boolean),
    [formData.certificationsText],
  );

  const loadMyProfile = async () => {
    try {
      setLoading(true);
      const res = await nutritionistsApi.getMyProfessionalProfile();
      const profile = res?.data?.data;

      if (profile) {
        setHasProfile(true);
        setFormData({
          fullName: profile.fullName || "",
          specialization: profile.specialization || "",
          experience: profile.experience?.toString() || "",
          certificationsText: (profile.certifications_url || []).join("\n"),
        });
      } else {
        setHasProfile(false);
        setFormData(INITIAL_FORM);
      }
    } catch (error) {
      toast.error(error?.response?.data?.message || "Failed to load professional profile");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadMyProfile();
  }, []);

  const handleChange = (field) => (event) => {
    setFormData((prev) => ({
      ...prev,
      [field]: event.target.value,
    }));
  };

  const handleSubmit = async (event) => {
    event.preventDefault();

    const payload = {
      fullName: formData.fullName.trim(),
      specialization: formData.specialization.trim(),
      experience: Number(formData.experience),
      certifications_url: certificationsPreview,
    };

    if (!payload.fullName || !payload.specialization || !Number.isFinite(payload.experience)) {
      toast.error("Full name, specialization and experience are required");
      return;
    }

    try {
      setSaving(true);
      const res = await nutritionistsApi.upsertMyProfessionalProfile(payload);
      toast.success(res?.data?.message || "Professional profile saved successfully");
      setHasProfile(true);
      await loadMyProfile();
    } catch (error) {
      toast.error(error?.response?.data?.message || "Failed to save professional profile");
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return <p style={{ color: "#666" }}>Loading professional profile...</p>;
  }

  return (
    <div>
      <h2 style={{ color: "#30a5ff", marginBottom: "8px" }}>
        <UserCog size={24} style={{ verticalAlign: "middle", marginRight: "8px" }} />
        Update Professional Profile
      </h2>
      <p style={{ color: "#777", marginTop: 0, marginBottom: "18px" }}>
        {hasProfile
          ? "Update your professional details shown to users."
          : "Create your professional profile so users can see your expertise."}
      </p>

      <form
        onSubmit={handleSubmit}
        style={{
          background: "#fff",
          borderRadius: "8px",
          boxShadow: "0 1px 2px rgba(0,0,0,0.1)",
          padding: "24px",
          maxWidth: "760px",
        }}
      >
        <div style={{ marginBottom: "16px" }}>
          <label style={{ display: "block", marginBottom: "8px", fontWeight: 600 }}>Full Name *</label>
          <input
            type="text"
            value={formData.fullName}
            onChange={handleChange("fullName")}
            placeholder="Enter your full name"
            required
            style={{ width: "100%", padding: "10px 12px", border: "1px solid #ddd", borderRadius: "6px" }}
          />
        </div>

        <div style={{ marginBottom: "16px" }}>
          <label style={{ display: "block", marginBottom: "8px", fontWeight: 600 }}>Specialization *</label>
          <input
            type="text"
            value={formData.specialization}
            onChange={handleChange("specialization")}
            placeholder="e.g. Sports Nutrition"
            required
            style={{ width: "100%", padding: "10px 12px", border: "1px solid #ddd", borderRadius: "6px" }}
          />
        </div>

        <div style={{ marginBottom: "16px" }}>
          <label style={{ display: "block", marginBottom: "8px", fontWeight: 600 }}>Experience (years) *</label>
          <input
            type="number"
            min="0"
            value={formData.experience}
            onChange={handleChange("experience")}
            placeholder="e.g. 5"
            required
            style={{ width: "100%", padding: "10px 12px", border: "1px solid #ddd", borderRadius: "6px" }}
          />
        </div>

        <div style={{ marginBottom: "16px" }}>
          <label style={{ display: "block", marginBottom: "8px", fontWeight: 600 }}>
            Certification URLs (one per line)
          </label>
          <textarea
            rows="5"
            value={formData.certificationsText}
            onChange={handleChange("certificationsText")}
            placeholder="https://example.com/cert-1\nhttps://example.com/cert-2"
            style={{ width: "100%", padding: "10px 12px", border: "1px solid #ddd", borderRadius: "6px" }}
          />
          <p style={{ color: "#777", marginTop: "8px", marginBottom: 0 }}>
            Parsed certifications: {certificationsPreview.length}
          </p>
        </div>

        <button
          type="submit"
          disabled={saving}
          style={{
            background: "#30a5ff",
            color: "#fff",
            border: "none",
            borderRadius: "6px",
            padding: "10px 16px",
            cursor: saving ? "not-allowed" : "pointer",
            display: "inline-flex",
            alignItems: "center",
            gap: "8px",
            fontWeight: 600,
            opacity: saving ? 0.7 : 1,
          }}
        >
          <Save size={16} /> {saving ? "Saving..." : "Save Profile"}
        </button>
      </form>
    </div>
  );
};

export default NutritionistProfessionalProfilePage;
