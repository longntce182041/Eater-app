// Script to list available Gemini models for your API key
const axios = require("axios");
require("dotenv").config({ path: "../.env" });

const apiKey = process.env.GOOGLE_API_KEY;
if (!apiKey) {
  console.error("Missing GOOGLE_API_KEY in .env");
  process.exit(1);
}

console.log("GOOGLE_API_KEY:", process.env.GOOGLE_API_KEY);

async function listModels() {
  try {
    const url = `https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey}`;
    const res = await axios.get(url);
    if (!res.data.models) {
      console.log("No models found.");
      return;
    }
    console.log("Available Gemini models:");
    for (const model of res.data.models) {
      console.log(`- name: ${model.name}`);
      if (model.displayName) console.log(`  displayName: ${model.displayName}`);
      if (model.supportedGenerationMethods)
        console.log(
          `  supportedGenerationMethods: ${model.supportedGenerationMethods.join(", ")}`,
        );
      if (model.description) console.log(`  description: ${model.description}`);
      console.log("");
    }
  } catch (err) {
    console.error("Error listing models:", err.response?.data || err.message);
  }
}

listModels();
