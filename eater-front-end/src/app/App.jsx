import React from "react";
import { AppLayout } from "./AppLayout";
import { AppRoutes } from "../routes/AppRoutes";

export default function App() {
  return (
    <AppLayout>
      <AppRoutes />
    </AppLayout>
  );
}
