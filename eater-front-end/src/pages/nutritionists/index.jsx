import React, { useEffect, useState } from "react";
import { Edit, Filter, Plus, Search, Trash2, UserCheck, X } from "lucide-react";
import { toast } from "react-toastify";
import { nutritionistsApi } from "../../services/nutritionistsApi";

const DEFAULT_FORM = {
  email: "",
  password: "",
  fullName: "",
  specialization: "",
  experience: "",
  certificationsText: "",
  verified: false,
};

const NutritionistsPage = () => {
  const [nutritionists, setNutritionists] = useState([]);
  const [loading, setLoading] = useState(true);

  const [filters, setFilters] = useState({
    keyword: "",
    specialization: "",
    verified: "",
  });

  const [showModal, setShowModal] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [currentNutritionist, setCurrentNutritionist] = useState(null);
  const [formData, setFormData] = useState(DEFAULT_FORM);

  const fetchNutritionists = async () => {
    try {
      setLoading(true);
      // Build params từ bộ lọc UI để truy vấn danh sách nutritionist trên server.
      const params = {
        keyword: filters.keyword,
        specialization: filters.specialization,
      };
      if (filters.verified !== "") {
        params.verified = filters.verified;
      }

      const res = await nutritionistsApi.getNutritionists(params);
      if (res.data.success) {
        setNutritionists(res.data.data.nutritionists || []);
      }
    } catch (error) {
      toast.error(
        error.response?.data?.message || "Failed to fetch nutritionists",
      );
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    // Debounce đơn giản khi người dùng gõ filter/search để tránh spam API.
    const timer = setTimeout(() => {
      fetchNutritionists();
    }, 350);
    return () => clearTimeout(timer);
  }, [filters]);

  const handleOpenCreate = () => {
    // Mở modal chế độ tạo mới profile nutritionist.
    setIsEditing(false);
    setCurrentNutritionist(null);
    setFormData(DEFAULT_FORM);
    setShowModal(true);
  };

  const handleOpenEdit = (nutritionist) => {
    // Mở modal chế độ sửa: map dữ liệu record hiện tại vào form.
    setIsEditing(true);
    setCurrentNutritionist(nutritionist);
    setFormData({
      email: nutritionist.userId?.email || "",
      password: "",
      fullName: nutritionist.fullName || "",
      specialization: nutritionist.specialization || "",
      experience: nutritionist.experience ?? "",
      certificationsText: (nutritionist.certifications_url || []).join("\n"),
      verified: !!nutritionist.verified,
    });
    setShowModal(true);
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Delete this nutritionist profile?")) return;
    try {
      const res = await nutritionistsApi.deleteNutritionist(id);
      toast.success(res.data.message || "Nutritionist deleted");
      await fetchNutritionists();
    } catch (error) {
      toast.error(
        error.response?.data?.message || "Failed to delete nutritionist",
      );
    }
  };

  const parseCertifications = (rawText) =>
    rawText
      .split("\n")
      .map((line) => line.trim())
      .filter(Boolean);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      let res;
      if (isEditing) {
        // Luồng UPDATE nutritionist profile hiện có.
        const payload = {
          fullName: formData.fullName.trim(),
          specialization: formData.specialization.trim(),
          experience: Number(formData.experience),
          certifications_url: parseCertifications(formData.certificationsText),
          verified: !!formData.verified,
        };
        res = await nutritionistsApi.updateNutritionist(
          currentNutritionist._id,
          payload,
        );
      } else {
        // Luồng CREATE nutritionist mới (bao gồm tài khoản user + profile nghề nghiệp).
        const payload = {
          email: formData.email.trim(),
          password: formData.password,
          fullName: formData.fullName.trim(),
          specialization: formData.specialization.trim(),
          experience: Number(formData.experience),
          certifications_url: parseCertifications(formData.certificationsText),
          verified: !!formData.verified,
        };
        res = await nutritionistsApi.createNutritionist(payload);
      }

      toast.success(res.data.message || "Saved successfully");
      setShowModal(false);
      // Reload danh sách để phản ánh dữ liệu mới nhất sau khi create/update.
      await fetchNutritionists();
    } catch (error) {
      const apiErrors = error.response?.data?.errors;
      if (apiErrors) {
        const firstError = Object.values(apiErrors)[0];
        toast.error(Array.isArray(firstError) ? firstError[0] : firstError);
      } else {
        toast.error(error.response?.data?.message || "Action failed");
      }
    }
  };

  return (
    <div>
      <h2 style={{ color: "#30a5ff", marginBottom: "20px" }}>
        Nutritionists Management
      </h2>

      <div
        style={{
          background: "white",
          padding: "15px",
          borderRadius: "5px",
          marginBottom: "20px",
          display: "flex",
          gap: "15px",
          alignItems: "center",
          boxShadow: "0 1px 2px rgba(0,0,0,0.1)",
        }}
      >
        <div style={{ position: "relative", flex: 1 }}>
          <Search
            size={18}
            style={{
              position: "absolute",
              left: "10px",
              top: "50%",
              transform: "translateY(-50%)",
              color: "#999",
            }}
          />
          <input
            type="text"
            placeholder="Search by name or specialization..."
            value={filters.keyword}
            onChange={(e) =>
              setFilters({ ...filters, keyword: e.target.value })
            }
            style={{
              width: "100%",
              padding: "10px 10px 10px 35px",
              borderRadius: "4px",
              border: "1px solid #ddd",
            }}
          />
        </div>

        <div style={{ position: "relative", width: "220px" }}>
          <Filter
            size={16}
            style={{
              position: "absolute",
              left: "10px",
              top: "50%",
              transform: "translateY(-50%)",
              color: "#999",
            }}
          />
          <input
            type="text"
            placeholder="Filter specialization"
            value={filters.specialization}
            onChange={(e) =>
              setFilters({ ...filters, specialization: e.target.value })
            }
            style={{
              width: "100%",
              padding: "10px 10px 10px 35px",
              borderRadius: "4px",
              border: "1px solid #ddd",
            }}
          />
        </div>

        <div style={{ position: "relative", width: "180px" }}>
          <UserCheck
            size={16}
            style={{
              position: "absolute",
              left: "10px",
              top: "50%",
              transform: "translateY(-50%)",
              color: "#999",
            }}
          />
          <select
            value={filters.verified}
            onChange={(e) =>
              setFilters({ ...filters, verified: e.target.value })
            }
            style={{
              width: "100%",
              padding: "10px 10px 10px 35px",
              borderRadius: "4px",
              border: "1px solid #ddd",
              cursor: "pointer",
            }}
          >
            <option value="">All verification</option>
            <option value="true">Verified</option>
            <option value="false">Not verified</option>
          </select>
        </div>

        <button
          onClick={handleOpenCreate}
          style={{
            background: "#30a5ff",
            color: "white",
            border: "none",
            padding: "10px 20px",
            borderRadius: "4px",
            cursor: "pointer",
            display: "flex",
            alignItems: "center",
            gap: "5px",
            fontWeight: "bold",
            whiteSpace: "nowrap",
          }}
        >
          <Plus size={18} /> Create Nutritionist
        </button>
      </div>

      <div
        style={{
          background: "white",
          padding: "20px",
          borderRadius: "5px",
          boxShadow: "0 1px 2px rgba(0,0,0,0.1)",
        }}
      >
        {loading ? (
          <p style={{ textAlign: "center", color: "#666" }}>Loading data...</p>
        ) : (
          <table style={{ width: "100%", borderCollapse: "collapse" }}>
            <thead>
              <tr
                style={{
                  borderBottom: "2px solid #eee",
                  textAlign: "left",
                  color: "#5f6468",
                }}
              >
                <th style={{ padding: "10px" }}>Full Name</th>
                <th style={{ padding: "10px" }}>Email</th>
                <th style={{ padding: "10px" }}>Specialization</th>
                <th style={{ padding: "10px" }}>Experience</th>
                <th style={{ padding: "10px" }}>Verified</th>
                <th style={{ padding: "10px" }}>Actions</th>
              </tr>
            </thead>
            <tbody>
              {nutritionists.length ? (
                nutritionists.map((item) => (
                  <tr
                    key={item._id}
                    style={{ borderBottom: "1px solid #eee", color: "#666" }}
                  >
                    <td style={{ padding: "12px" }}>{item.fullName}</td>
                    <td style={{ padding: "12px" }}>
                      {item.userId?.email || "-"}
                    </td>
                    <td style={{ padding: "12px" }}>{item.specialization}</td>
                    <td style={{ padding: "12px" }}>{item.experience} years</td>
                    <td style={{ padding: "12px" }}>
                      {item.verified ? (
                        <span style={{ color: "#28a745", fontWeight: "bold" }}>
                          Verified
                        </span>
                      ) : (
                        <span style={{ color: "#f0ad4e", fontWeight: "bold" }}>
                          Pending
                        </span>
                      )}
                    </td>
                    <td style={{ padding: "12px" }}>
                      <button
                        onClick={() => handleOpenEdit(item)}
                        style={{
                          marginRight: "10px",
                          border: "none",
                          background: "none",
                          cursor: "pointer",
                          color: "#30a5ff",
                        }}
                      >
                        <Edit size={18} />
                      </button>
                      <button
                        onClick={() => handleDelete(item._id)}
                        style={{
                          border: "none",
                          background: "none",
                          cursor: "pointer",
                          color: "#f9243f",
                        }}
                      >
                        <Trash2 size={18} />
                      </button>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td
                    colSpan="6"
                    style={{ textAlign: "center", padding: "20px" }}
                  >
                    No nutritionists found.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        )}
      </div>

      {showModal && (
        <div
          style={{
            position: "fixed",
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            background: "rgba(0,0,0,0.5)",
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
            zIndex: 1000,
          }}
        >
          <div
            style={{
              background: "white",
              padding: "30px",
              borderRadius: "8px",
              width: "460px",
              position: "relative",
            }}
          >
            <button
              onClick={() => setShowModal(false)}
              style={{
                position: "absolute",
                top: "15px",
                right: "15px",
                background: "none",
                border: "none",
                cursor: "pointer",
              }}
            >
              <X size={20} />
            </button>

            <h3 style={{ marginTop: 0, color: "#30a5ff" }}>
              {isEditing ? "Edit Nutritionist" : "Create Nutritionist"}
            </h3>

            <form onSubmit={handleSubmit}>
              {!isEditing && (
                <>
                  <div style={{ marginBottom: "12px" }}>
                    <label
                      style={{
                        display: "block",
                        marginBottom: "5px",
                        fontSize: "14px",
                      }}
                    >
                      Email
                    </label>
                    <input
                      type="email"
                      value={formData.email}
                      onChange={(e) =>
                        setFormData({ ...formData, email: e.target.value })
                      }
                      style={{
                        width: "100%",
                        padding: "8px",
                        borderRadius: "4px",
                        border: "1px solid #ccc",
                      }}
                      required
                    />
                  </div>

                  <div style={{ marginBottom: "12px" }}>
                    <label
                      style={{
                        display: "block",
                        marginBottom: "5px",
                        fontSize: "14px",
                      }}
                    >
                      Password
                    </label>
                    <input
                      type="password"
                      value={formData.password}
                      onChange={(e) =>
                        setFormData({ ...formData, password: e.target.value })
                      }
                      style={{
                        width: "100%",
                        padding: "8px",
                        borderRadius: "4px",
                        border: "1px solid #ccc",
                      }}
                      minLength={6}
                      required
                    />
                  </div>
                </>
              )}

              <div style={{ marginBottom: "12px" }}>
                <label
                  style={{
                    display: "block",
                    marginBottom: "5px",
                    fontSize: "14px",
                  }}
                >
                  Full Name
                </label>
                <input
                  type="text"
                  value={formData.fullName}
                  onChange={(e) =>
                    setFormData({ ...formData, fullName: e.target.value })
                  }
                  style={{
                    width: "100%",
                    padding: "8px",
                    borderRadius: "4px",
                    border: "1px solid #ccc",
                  }}
                  required
                />
              </div>

              <div style={{ marginBottom: "12px" }}>
                <label
                  style={{
                    display: "block",
                    marginBottom: "5px",
                    fontSize: "14px",
                  }}
                >
                  Specialization
                </label>
                <input
                  type="text"
                  value={formData.specialization}
                  onChange={(e) =>
                    setFormData({ ...formData, specialization: e.target.value })
                  }
                  style={{
                    width: "100%",
                    padding: "8px",
                    borderRadius: "4px",
                    border: "1px solid #ccc",
                  }}
                  required
                />
              </div>

              <div style={{ marginBottom: "12px" }}>
                <label
                  style={{
                    display: "block",
                    marginBottom: "5px",
                    fontSize: "14px",
                  }}
                >
                  Experience (years)
                </label>
                <input
                  type="number"
                  min="0"
                  value={formData.experience}
                  onChange={(e) =>
                    setFormData({ ...formData, experience: e.target.value })
                  }
                  style={{
                    width: "100%",
                    padding: "8px",
                    borderRadius: "4px",
                    border: "1px solid #ccc",
                  }}
                  required
                />
              </div>

              <div style={{ marginBottom: "12px" }}>
                <label
                  style={{
                    display: "block",
                    marginBottom: "5px",
                    fontSize: "14px",
                  }}
                >
                  Certifications URLs (one per line)
                </label>
                <textarea
                  rows="3"
                  value={formData.certificationsText}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      certificationsText: e.target.value,
                    })
                  }
                  style={{
                    width: "100%",
                    padding: "8px",
                    borderRadius: "4px",
                    border: "1px solid #ccc",
                    resize: "vertical",
                  }}
                  placeholder={"https://cert-1.com\nhttps://cert-2.com"}
                />
              </div>

              <div style={{ marginBottom: "18px" }}>
                <label
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: "10px",
                    fontSize: "14px",
                    cursor: "pointer",
                  }}
                >
                  <input
                    type="checkbox"
                    checked={formData.verified}
                    onChange={(e) =>
                      setFormData({ ...formData, verified: e.target.checked })
                    }
                  />
                  Verified profile
                </label>
              </div>

              <button
                type="submit"
                style={{
                  width: "100%",
                  padding: "10px",
                  background: "#30a5ff",
                  color: "white",
                  border: "none",
                  borderRadius: "4px",
                  cursor: "pointer",
                  fontWeight: "bold",
                }}
              >
                {isEditing ? "Save Changes" : "Create Nutritionist"}
              </button>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default NutritionistsPage;
