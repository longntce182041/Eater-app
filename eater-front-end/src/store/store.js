// File: src/store/store.js

import { configureStore } from "@reduxjs/toolkit";
import authReducer from "./slices/authSlice.js";

// Minimal store configuration: include `auth` reducer so combineReducers is valid.
export const store = configureStore({
    reducer: {
        auth: authReducer,
    },
});