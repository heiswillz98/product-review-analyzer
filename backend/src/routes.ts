import express, { Request, Response } from "express";
import axios from "axios";

const router = express.Router();

router.post("/", async (req: Request, res: Response) => {
  const { text } = req.body;

  if (!text || typeof text !== "string") {
    res.status(400).json({ error: 'Missing or invalid "text" field' });
    return;
  }

  try {
    const mlResponse = await axios.post("http://ml-service:8000/predict", {
      text,
    });
    res.json(mlResponse.data);
    return;
  } catch (err: any) {
    console.error("❌ ML API error:", err.message || err);
    res.status(500).json({ error: "Failed to analyze sentiment" });
    return;
  }
});

export default router;

// import express from "express";
// import axios from "axios";

// const router = express.Router();

// router.post("/", async (req, res) => {
//   const { text } = req.body;

//   if (!text || typeof text !== "string") {
//     res.status(400).json({ error: 'Missing or invalid "text" field' });
//     return;
//   }

//   try {
//     const mlResponse = await axios.post(
//       "http://localhost:8000/predict",
//       { text },
//       {
//         headers: {
//           "Content-Type": "application/json",
//           "User-Agent": "Node.js Backend",
//         },
//       }
//     );

//     res.json(mlResponse.data);
//     return;
//   } catch (err: any) {
//     console.error("❌ ML API error:", err.message || err);
//     res.status(500).json({ error: "Failed to analyze sentiment" });
//     return;
//   }
// });

// export default router;
