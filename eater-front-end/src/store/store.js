// File: src/store/store.js

import { configureStore } from "@reduxjs/toolkit";

// --- KHI NÀO CÓ FILE SLICE THÌ BỎ COMMENT CÁC DÒNG DƯỚI ---
// import authReducer from "./slices/authSlice.js";
// import usersReducer from "./slices/usersSlice.js";
// ... các import khác

export const store = configureStore({
    reducer: {
        // auth: authReducer,
        // users: usersReducer,
        // ...
    },
});