import React from "react";
import { ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import { AppLayout } from "./AppLayout";
import { AppRoutes } from "../routes/AppRoutes";

export default function App() {
  return (
    <AppLayout>
      <AppRoutes />
      <ToastContainer position="top-right" autoClose={3000} />
    </AppLayout>
  );
}
