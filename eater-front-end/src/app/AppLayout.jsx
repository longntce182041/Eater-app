import React from "react";

// Basic shell: sidebar, header, main content (no styling)
export function AppLayout({ children }) {
  return (
    <div className="app-layout">
      <header></header>
      <div className="app-body">
        <aside></aside>
        <main>{children}</main>
      </div>
    </div>
  );
}
