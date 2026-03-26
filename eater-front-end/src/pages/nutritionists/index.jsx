import React, { useEffect, useState } from "react";
import { Save, Plus, Trash2, AlertCircle, CheckCircle2 } from "lucide-react";
import {
	getMyProfessionalProfile,
	upsertMyProfessionalProfile,
} from "../../services/nutritionistsApi";

const NutritionistProfilePage = () => {
	const [loading, setLoading] = useState(true);
	const [saving, setSaving] = useState(false);
	const [error, setError] = useState("");
	const [success, setSuccess] = useState("");
	const [hasProfile, setHasProfile] = useState(false);
	const [form, setForm] = useState({
		fullName: "",
		specialization: "",
		experience: "",
		certifications_url: [""],
	});

	useEffect(() => {
		fetchProfile();
	}, []);

	const fetchProfile = async () => {
		try {
			setLoading(true);
			setError("");
			const res = await getMyProfessionalProfile();
			const profile = res?.data;

			if (profile) {
				setHasProfile(true);
				setForm({
					fullName: profile.fullName || "",
					specialization: profile.specialization || "",
					experience:
						profile.experience === 0 || profile.experience
							? String(profile.experience)
							: "",
					certifications_url:
						profile.certifications_url && profile.certifications_url.length > 0
							? profile.certifications_url
							: [""],
				});
			} else {
				setHasProfile(false);
			}
		} catch (err) {
			setError(err?.response?.data?.message || "Failed to load professional profile");
		} finally {
			setLoading(false);
		}
	};

	const updateCertification = (index, value) => {
		const next = [...form.certifications_url];
		next[index] = value;
		setForm({ ...form, certifications_url: next });
	};

	const addCertificationField = () => {
		setForm({ ...form, certifications_url: [...form.certifications_url, ""] });
	};

	const removeCertificationField = (index) => {
		const next = form.certifications_url.filter((_, i) => i !== index);
		setForm({ ...form, certifications_url: next.length ? next : [""] });
	};

	const handleSubmit = async (e) => {
		e.preventDefault();
		setSaving(true);
		setError("");
		setSuccess("");

		try {
			const specialization = form.specialization.trim();
			const specializationPattern = /^[\p{L}\s]+$/u;
			if (!specializationPattern.test(specialization)) {
				setError("Specialization can only contain letters and spaces");
				setSaving(false);
				return;
			}

			const normalizeUrl = (value) =>
				value.trim().toLowerCase().replace(/\/+$/, "");

			const certs = form.certifications_url
				.map((x) => x.trim())
				.filter(Boolean);

			const normalizedCerts = certs.map(normalizeUrl);
			if (new Set(normalizedCerts).size !== normalizedCerts.length) {
				setError("Duplicate certification links are not allowed");
				setSaving(false);
				return;
			}

			const payload = {
				fullName: form.fullName.trim(),
				specialization,
				experience: Number(form.experience),
				certifications_url: certs,
			};

			await upsertMyProfessionalProfile(payload);
			setHasProfile(true);
			setSuccess("Professional profile saved successfully");
		} catch (err) {
			setError(err?.response?.data?.message || "Failed to save professional profile");
		} finally {
			setSaving(false);
		}
	};

	if (loading) {
		return <div style={{ padding: 20 }}>Loading professional profile...</div>;
	}

	return (
		<div style={{ padding: 20, maxWidth: 900 }}>
			<h2 style={{ marginBottom: 8, color: "#30a5ff" }}>Professional Profile</h2>
			<p style={{ color: "#666", marginBottom: 20 }}>
				{hasProfile
					? "Manage your professional profile and certifications"
					: "Create your professional profile and certifications"}
			</p>

			{error && (
				<div
					style={{
						marginBottom: 16,
						padding: 12,
						borderRadius: 8,
						background: "#fff1f1",
						border: "1px solid #ffd0d0",
						color: "#a30000",
						display: "flex",
						gap: 8,
						alignItems: "center",
					}}
				>
					<AlertCircle size={18} /> {error}
				</div>
			)}

			{success && (
				<div
					style={{
						marginBottom: 16,
						padding: 12,
						borderRadius: 8,
						background: "#effcf3",
						border: "1px solid #b8efc4",
						color: "#0f6b28",
						display: "flex",
						gap: 8,
						alignItems: "center",
					}}
				>
					<CheckCircle2 size={18} /> {success}
				</div>
			)}

			<form
				onSubmit={handleSubmit}
				style={{
					background: "#fff",
					border: "1px solid #e8e8e8",
					borderRadius: 12,
					padding: 20,
					boxShadow: "0 1px 2px rgba(0,0,0,0.06)",
				}}
			>
				<div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16 }}>
					<div>
						<label style={{ display: "block", marginBottom: 8, fontWeight: 600 }}>Full Name *</label>
						<input
							type="text"
							value={form.fullName}
							onChange={(e) => setForm({ ...form, fullName: e.target.value })}
							required
							style={{ width: "100%", padding: 10, border: "1px solid #ddd", borderRadius: 8 }}
						/>
					</div>

					<div>
						<label style={{ display: "block", marginBottom: 8, fontWeight: 600 }}>Specialization *</label>
						<input
							type="text"
							value={form.specialization}
							onChange={(e) => setForm({ ...form, specialization: e.target.value })}
							required
							style={{ width: "100%", padding: 10, border: "1px solid #ddd", borderRadius: 8 }}
						/>
					</div>
				</div>

				<div style={{ marginTop: 16 }}>
					<label style={{ display: "block", marginBottom: 8, fontWeight: 600 }}>Experience (years) *</label>
					<input
						type="number"
						min="0"
						step="1"
						value={form.experience}
						onChange={(e) => setForm({ ...form, experience: e.target.value })}
						required
						style={{ width: "100%", maxWidth: 260, padding: 10, border: "1px solid #ddd", borderRadius: 8 }}
					/>
				</div>

				<div style={{ marginTop: 20 }}>
					<div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
						<label style={{ fontWeight: 600 }}>Certifications (URL)</label>
						<button
							type="button"
							onClick={addCertificationField}
							style={{ border: "1px solid #ddd", background: "#fff", borderRadius: 8, padding: "6px 10px", cursor: "pointer", display: "flex", gap: 6, alignItems: "center" }}
						>
							<Plus size={16} /> Add
						</button>
					</div>

					<div style={{ display: "grid", gap: 10 }}>
						{form.certifications_url.map((cert, index) => (
							<div key={index} style={{ display: "flex", gap: 8 }}>
								<input
									type="url"
									placeholder="https://..."
									value={cert}
									onChange={(e) => updateCertification(index, e.target.value)}
									style={{ flex: 1, padding: 10, border: "1px solid #ddd", borderRadius: 8 }}
								/>
								<button
									type="button"
									onClick={() => removeCertificationField(index)}
									style={{ border: "1px solid #ffd6d6", color: "#c70000", background: "#fff5f5", borderRadius: 8, padding: "0 10px", cursor: "pointer" }}
									title="Remove"
								>
									<Trash2 size={16} />
								</button>
							</div>
						))}
					</div>
				</div>

				<div style={{ marginTop: 20 }}>
					<button
						type="submit"
						disabled={saving}
						style={{
							border: "none",
							background: "#30a5ff",
							color: "#fff",
							borderRadius: 8,
							padding: "10px 16px",
							cursor: saving ? "not-allowed" : "pointer",
							display: "inline-flex",
							gap: 8,
							alignItems: "center",
							fontWeight: 600,
						}}
					>
						<Save size={16} /> {saving ? "Saving..." : "Save Profile"}
					</button>
				</div>
			</form>
		</div>
	);
};

export default NutritionistProfilePage;
