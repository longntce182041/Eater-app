import axios from "axios";

const axiosClient = axios.create({
  baseURL: "http://localhost:3000/api", // Backend chạy port 3000
  headers: {
    "Content-Type": "application/json",
  },
});

// Tự động thêm Token vào Header trước khi gửi request
axiosClient.interceptors.request.use((config) => {
  const token = localStorage.getItem("token"); // Lưu ý: Lúc login xong phải lưu token vào localStorage
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default axiosClient;
