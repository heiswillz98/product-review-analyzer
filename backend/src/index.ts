import express from "express";
import cors from "cors";
import analyzeRoute from "./routes";

const app = express();
const PORT = process.env.PORT || 5001;

app.use(cors());
app.use(express.json());
app.use("/analyze", analyzeRoute);

app.listen(PORT, () => {
  console.log(`🔁 Backend listening on http://localhost:${PORT}`);
});
