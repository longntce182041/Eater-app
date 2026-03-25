const { default: mongoose } = require("mongoose");

const UserProSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    startDate: { type: Date, default: Date.now },
    endDate: { type: Date, required: true },
    isActive: { type: Boolean, default: true },
    plan_type: {
      type: String,
      enum: ["monthly", "yearly"],
      default: "monthly",
    },
    plan_duration_days: { type: Number, default: 30 },
    plan_amount: { type: Number },
    // PayOS specific fields

    payos_order_code: { type: Number, unique: true, sparse: true },
    payos_transaction_id: { type: String },
    payos_payment_link: { type: String },
    payos_qr_code: { type: String },

    created_at: { type: Date, default: Date.now },
  },
  { timestamps: true },
);

const UserPro = mongoose.model("UserPro", UserProSchema);

module.exports = UserPro;
