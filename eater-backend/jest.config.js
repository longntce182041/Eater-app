/** @type {import('jest').Config} */
module.exports = {
  // Thư mục gốc của source code
  roots: ["<rootDir>/src", "<rootDir>/tests"],

  // Môi trường chạy test (backend → node)
  testEnvironment: "node",

  // Pattern để Jest tìm file test
  testMatch: ["**/__tests__/**/*.test.js", "**/?(*.)+(spec|test).js"],

  // Dùng Babel (nếu bạn dùng ES6 import hoặc TypeScript)
  // Nếu chỉ dùng require() bình thường thì có thể bỏ phần này.
  transform: {
    "^.+\\.jsx?$": "babel-jest",
  },

  // Bỏ qua một số thư mục khi chạy test
  testPathIgnorePatterns: ["/node_modules/", "/dist/"],

  // Thu thập coverage (tùy chọn, nhưng tốt cho đồ án)
  collectCoverage: true,
  collectCoverageFrom: [
    "src/**/*.js",
    "!src/server.js", // thường bỏ qua file bootstrap
    "!src/app.js",
  ],
  coverageDirectory: "coverage",

  // Thiết lập biến môi trường trước khi chạy test (nếu cần)
  setupFiles: ["<rootDir>/tests/setupEnv.js"],

  // Nếu dùng module alias, có thể map ở đây
  // moduleNameMapper: {...}
};
