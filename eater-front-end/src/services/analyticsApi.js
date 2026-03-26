import axiosClient from "../api/axiosClient";

export async function getAnalyticsOverview() {
    const response = await axiosClient.get("/analytics/overview");
    return response?.data?.data;
}

