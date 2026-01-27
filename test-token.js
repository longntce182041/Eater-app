const jwt = require("jsonwebtoken");

const token = jwt.sign({ id: "123", role: "user" }, "dev-secret", {
  expiresIn: "1h",
});

console.log("Token:", token);
