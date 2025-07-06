import { useState } from "react";
import axios from "axios";

interface SentimentResult {
  sentiment: string;
  label: string;
  confidence: number;
}

function App() {
  const [text, setText] = useState("");
  const [result, setResult] = useState<SentimentResult | null>(null);
  const [loading, setLoading] = useState(false);

  const analyze = async () => {
    setLoading(true);
    try {
      const res = await axios.post(`${import.meta.env.VITE_API_URL}/analyze`, {
        text,
      });
      setResult(res.data);
    } catch (err) {
      alert("Error analyzing sentiment");
    } finally {
      setLoading(false);
    }
  };

  const containerStyle: React.CSSProperties = {
    minHeight: "100vh",
    backgroundColor: "#f3f4f6",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    justifyContent: "center",
    padding: "1rem",
  };

  const textareaStyle: React.CSSProperties = {
    width: "100%",
    maxWidth: "600px",
    padding: "1rem",
    border: "1px solid #ccc",
    borderRadius: "6px",
    marginBottom: "1rem",
    fontSize: "1rem",
  };

  const buttonStyle: React.CSSProperties = {
    backgroundColor: "#2563eb",
    color: "#fff",
    padding: "0.75rem 1.5rem",
    borderRadius: "6px",
    border: "none",
    fontWeight: "bold",
    cursor: "pointer",
    opacity: loading || !text.trim() ? 0.6 : 1,
  };

  const cardStyle: React.CSSProperties = {
    marginTop: "1.5rem",
    backgroundColor: "#fff",
    boxShadow: "0 2px 6px rgba(0, 0, 0, 0.1)",
    padding: "1rem",
    borderRadius: "6px",
    width: "100%",
    maxWidth: "600px",
  };

  return (
    <div style={containerStyle}>
      <h1
        style={{ fontSize: "1.5rem", fontWeight: "bold", marginBottom: "1rem" }}
      >
        🛍️ Product Review Analyzer
      </h1>
      <p
        style={{
          fontSize: "1rem",
          color: "#555",
          maxWidth: "500px",
          textAlign: "center",
          marginBottom: "2rem",
        }}
      >
        Ever screamed into a product review? 😤 Or typed "love it!!!" at 2am?
        This app reads your emotional chaos and tells you what your review{" "}
        <em>really</em> means. 🎯
      </p>

      <textarea
        value={text}
        onChange={(e) => setText(e.target.value)}
        placeholder="Enter your product review..."
        style={textareaStyle}
        rows={5}
      />
      <button
        onClick={analyze}
        disabled={loading || !text.trim()}
        style={buttonStyle}
      >
        {loading ? "Analyzing..." : "Analyze"}
      </button>

      {result && (
        <div style={cardStyle}>
          <p>
            <strong>Sentiment:</strong> {result.sentiment}
          </p>
          <p>
            <strong>Label:</strong> {result.label}
          </p>
          <p>
            <strong>Confidence:</strong> {Math.round(result.confidence * 100)}%
          </p>
        </div>
      )}
    </div>
  );
}

export default App;
