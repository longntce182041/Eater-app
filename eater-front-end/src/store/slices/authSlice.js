import { createSlice } from '@reduxjs/toolkit';

const initialState = {
  token: typeof window !== 'undefined' ? localStorage.getItem('token') : null,
  userRole: typeof window !== 'undefined' ? localStorage.getItem('userRole') : null,
};

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    setCredentials(state, action) {
      state.token = action.payload.token;
      state.userRole = action.payload.userRole;
      if (typeof window !== 'undefined') {
        localStorage.setItem('token', action.payload.token);
        localStorage.setItem('userRole', action.payload.userRole);
      }
    },
    logout(state) {
      state.token = null;
      state.userRole = null;
      if (typeof window !== 'undefined') {
        localStorage.removeItem('token');
        localStorage.removeItem('userRole');
      }
    },
  },
});

export const { setCredentials, logout } = authSlice.actions;
export default authSlice.reducer;
