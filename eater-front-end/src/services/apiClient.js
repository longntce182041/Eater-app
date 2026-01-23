import axios from "axios";

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || "http://localhost:4000/api/v1",
  timeout: 10000,
});

// TODO: attach auth token interceptor if needed
apiClient.interceptors.request.use((config) => {
  // const token = localStorage.getItem("access_token");
  // if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

export default apiClient;
