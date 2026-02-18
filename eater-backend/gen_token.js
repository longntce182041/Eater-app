const jwt = require("jsonwebtoken");
const token = jwt.sign({ id: "test-user", role: "user" }, "dev-secret", {
  expiresIn: "1h",
});
console.log(token);
