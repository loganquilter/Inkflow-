const NICHES = [
{ id: "finance", label: "Personal Finance", emoji: "💰", cpc: "$4.20" },
{ id: "health", label: "Health & Wellness", emoji: "🏃", cpc: "$3.80" },
{ id: "tech", label: "Tech Reviews", emoji: "⚡", cpc: "$5.10" },
{ id: "travel", label: "Travel Guides", emoji: "✈️", cpc: "$2.90" },
{ id: "food", label: "Food & Recipes", emoji: "🍳", cpc: "$1.80" },
];

const PLANS = [
{ name: "Starter", price: 29, articles: 10, color: "#a8e6cf" },
{ name: "Growth", price: 79, articles: 40, color: "#ffd3b6", popular: true },
{ name: "Empire", price: 199, articles: 120, color: "#ffaaa5" },
];

const SAMPLE_TITLES = {
finance: [
"7 Index Funds That Beat the S&P 500 in 2025",
"How I Paid Off $40K in Debt Using the Snowball Method",
"Roth IRA vs Traditional: The Complete 2026 Guide",
],
health: [
"The 15-Minute Morning Routine That Changed My Life",
"10 High-Protein Breakfasts Under 400 Calories",
"Zone 2 Cardio: Why Every Doctor Is Talking About It",
],
tech: [
"Best Laptops Under $1000 — Tested & Ranked",
"I Used Claude vs ChatGPT for 30 Days. Here's What Happened",
"The Home Office Setup That Costs Less Than $300",
],
travel: [
"Japan on $60/Day: A Complete Budget Itinerary",
"The 12 Best Hidden Beaches in Southeast Asia",
"How to Get Upgraded on Flights (That Actually Works)",
],
food: [
"5-Ingredient Dinner Recipes Ready in 20 Minutes",
"The Science of Perfect Homemade Bread",
"Air Fryer Hacks: 30 Recipes You Haven't Tried",
],
};

function TypingText({ text, speed = 18 }) {
const [displayed, setDisplayed] = useState("");
const [done, setDone] = useState(false);
useEffect(() => {
setDisplayed("");
setDone(false);
let i = 0;
const iv = setInterval(() => {
if (i < text.length) { setDisplayed(text.slice(0, i + 1)); i++; }
else { setDone(true); clearInterval(iv); }
}, speed);
return () => clearInterval(iv);
}, [text]);
return <span>{displayed}{!done && <span style={{ animation: "blink 1s infinite" }}>|</span>}</span>;
}

function ArticleGenerator({ niche }) {
const [loading, setLoading] = useState(false);
const [article, setArticle] = useState(null);
const [title, setTitle] = useState("");
const [error, setError] = useState(null);
const nicheData = NICHES.find((n) => n.id === niche) || NICHES[0];
const sampleTitles = SAMPLE_TITLES[niche] || SAMPLE_TITLES.finance;

async function generateArticle() {
const chosenTitle = title.trim() || sampleTitles[Math.floor(Math.random() * sampleTitles.length)];
setLoading(true); setArticle(null); setError(null);
try {
const res = await fetch(PROXY_URL, {
method: "POST",
headers: { "Content-Type": "application/json" },
body: JSON.stringify({
model: "claude-sonnet-4-20250514",
max_tokens: 1000,
system: `You are an expert SEO content writer for a ${nicheData.label} blog. Always respond with a JSON object (no markdown, no backticks) with: title (string), hook (1 compelling opening sentence), sections (array of 3 objects with heading and body — 2-3 sentences each), cta (call-to-action sentence), seo_keywords (array of 5 strings), estimated_read_time (e.g. "4 min read"), ad_revenue_estimate (e.g. "$45–$120/mo at 5k views").`,
messages: [{ role: "user", content: `Write an SEO blog article about: "${chosenTitle}". Make it genuinely useful, engaging, and ad-friendly.` }],
}),
});
const data = await res.json();
const raw = data.content?.map((b) => b.text || "").join("") || "";
const parsed = JSON.parse(raw.replace(/```json|```/g, "").trim());
setArticle(parsed);
setTitle("");
} catch (e) {
setError("Generation failed. Make sure your Vercel proxy is deployed and PROXY_URL is set correctly.");
}
setLoading(false);
}

return (
<div style={{ fontFamily: "'Georgia', serif" }}>
<div style={{ display: "flex", gap: 10, marginBottom: 16, flexWrap: "wrap" }}>
<input
value={title} onChange={(e) => setTitle(e.target.value)}
placeholder={`e.g. "${sampleTitles[0]}"`}
style={{ flex: 1, minWidth: 220, padding: "10px 14px", borderRadius: 8, border: "2px solid #e8e0d5", fontSize: 14, fontFamily: "inherit", background: "#fdfaf7", outline: "none" }}
onKeyDown={(e) => e.key === "Enter" && generateArticle()}
/>
<button onClick={generateArticle} disabled={loading}
style={{ padding: "10px 22px", borderRadius: 8, border: "none", background: loading ? "#ccc" : "#2d2d2d", color: "#fff", fontFamily: "'Georgia', serif", fontSize: 14, cursor: loading ? "not-allowed" : "pointer", fontWeight: "bold", letterSpacing: 0.5 }}>
{loading ? "Writing…" : "✦ Generate Article"}
</button>
</div>

<div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 20 }}>
{sampleTitles.map((t) => (
<button key={t} onClick={() => setTitle(t)}
style={{ padding: "5px 12px", borderRadius: 20, border: "1.5px solid #d4c9b8", background: "#fdfaf7", fontSize: 12, cursor: "pointer", color: "#666", fontFamily: "inherit" }}>
{t.slice(0, 30)}…
</button>
))}
</div>

{error && <div style={{ color: "#c0392b", padding: 12, background: "#fdecea", borderRadius: 8, fontSize: 14 }}>{error}</div>}

{loading && (
<div style={{ textAlign: "center", padding: "40px 0", color: "#888" }}>
<div style={{ fontSize: 32, animation: "spin 1.2s linear infinite", display: "inline-block" }}>✦</div>
<div style={{ marginTop: 10, fontSize: 14 }}>Claude is writing your article…</div>
</div>
)}

{article && !loading && (
<div style={{ background: "#fdfaf7", borderRadius: 12, border: "1.5px solid #e8e0d5", padding: "28px 32px", animation: "fadeUp 0.5s ease" }}>
<div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", flexWrap: "wrap", gap: 8, marginBottom: 6 }}>
<span style={{ fontSize: 11, color: "#999", textTransform: "uppercase", letterSpacing: 1 }}>{nicheData.label} • {article.estimated_read_time}</span>
<span style={{ fontSize: 11, background: "#e8f5e9", color: "#2e7d32", padding: "3px 10px", borderRadius: 20 }}>Est. {article.ad_revenue_estimate}</span>
</div>
<h2 style={{ fontFamily: "'Georgia', serif", fontSize: 22, color: "#1a1a1a", margin: "8px 0 14px", lineHeight: 1.3 }}>
<TypingText text={article.title} speed={25} />
</h2>
<p style={{ color: "#555", fontSize: 15, lineHeight: 1.7, borderLeft: "3px solid #d4c9b8", paddingLeft: 14, marginBottom: 20, fontStyle: "italic" }}>{article.hook}</p>
{article.sections?.map((s, i) => (
<div key={i} style={{ marginBottom: 18 }}>
<h3 style={{ fontSize: 16, color: "#2d2d2d", marginBottom: 6 }}>{s.heading}</h3>
<p style={{ color: "#555", fontSize: 14, lineHeight: 1.75, margin: 0 }}>{s.body}</p>
</div>
))}
<div style={{ background: "#fff8f0", border: "1.5px solid #ffe0b2", borderRadius: 8, padding: "12px 16px", marginTop: 16, fontSize: 13, color: "#e65100" }}>📢 {article.cta}</div>
<div style={{ marginTop: 16, display: "flex", flexWrap: "wrap", gap: 6 }}>
{article.seo_keywords?.map((kw) => (
<span key={kw} style={{ background: "#f0f0f0", padding: "3px 10px", borderRadius: 20, fontSize: 11, color: "#555" }}>#{kw}</span>
))}
</div>
<div style={{ marginTop: 20, display: "flex", gap: 10, flexWrap: "wrap" }}>
<button style={{ flex: 1, padding: "10px 0", borderRadius: 8, border: "none", background: "#2d2d2d", color: "#fff", fontSize: 13, cursor: "pointer", fontFamily: "inherit" }}>📋 Copy to WordPress</button>
<button onClick={generateArticle} style={{ flex: 1, padding: "10px 0", borderRadius: 8, border: "1.5px solid #2d2d2d", background: "transparent", color: "#2d2d2d", fontSize: 13, cursor: "pointer", fontFamily: "inherit" }}>↺ Regenerate</button>
</div>
</div>
)}
</div>
);
}

export default function App() {
const [tab, setTab] = useState("dashboard");
const [selectedNiche, setSelectedNiche] = useState("finance");
const [revenue, setRevenue] = useState(0);

useEffect(() => {
let v = 0;
const t = setInterval(() => { v += 1.37; setRevenue(Math.min(v, 312.48)); if (v >= 312.48) clearInterval(t); }, 14);
return () => clearInterval(t);
}, []);

return (
<div style={{ minHeight: "100vh", background: "#f5f0e8", fontFamily: "'Georgia', serif", color: "#1a1a1a" }}>
<style>{`
@keyframes blink { 0%,100%{opacity:1} 50%{opacity:0} }
@keyframes spin { from{transform:rotate(0deg)} to{transform:rotate(360deg)} }
@keyframes fadeUp { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }
@keyframes ticker { from{transform:translateX(0)} to{transform:translateX(-50%)} }
* { box-sizing: border-box; }
`}</style>

{/* Header */}
<div style={{ background: "#1a1a1a", color: "#f5f0e8", padding: "14px 32px", display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: 10 }}>
<div style={{ display: "flex", alignItems: "center", gap: 10 }}>
<span style={{ fontSize: 22 }}>✦</span>
<span style={{ fontSize: 18, fontWeight: "bold", letterSpacing: 1 }}>INKFLOW</span>
<span style={{ fontSize: 11, color: "#888", marginLeft: 4, letterSpacing: 2, textTransform: "uppercase" }}>AI Content Empire</span>
</div>
<div style={{ display: "flex", gap: 6 }}>
{["dashboard", "generate", "pricing"].map((t) => (
<button key={t} onClick={() => setTab(t)}
style={{ padding: "6px 16px", borderRadius: 6, border: "none", cursor: "pointer", fontSize: 12, background: tab === t ? "#f5f0e8" : "transparent", color: tab === t ? "#1a1a1a" : "#aaa", textTransform: "capitalize", fontFamily: "inherit", letterSpacing: 0.5 }}>
{t}
</button>
))}
</div>
</div>

{/* Ticker */}
<div style={{ background: "#2d2d2d", color: "#a8e6cf", padding: "7px 0", fontSize: 11, overflow: "hidden", letterSpacing: 1 }}>
<div style={{ display: "flex", animation: "ticker 28s linear infinite", whiteSpace: "nowrap" }}>
{[...Array(2)].map((_, i) => (
<span key={i} style={{ paddingRight: 60 }}>
✦ FINANCE CPC: $4.20 &nbsp;&nbsp; ✦ TECH CPC: $5.10 &nbsp;&nbsp; ✦ HEALTH CPC: $3.80 &nbsp;&nbsp; ✦ TRAVEL CPC: $2.90 &nbsp;&nbsp; ✦ FOOD CPC: $1.80 &nbsp;&nbsp; ✦ AVG ARTICLE EARNS: $45–$320/mo &nbsp;&nbsp; ✦ AI WRITES WHILE YOU WORK &nbsp;&nbsp;
</span>
))}
</div>
</div>

<div style={{ maxWidth: 900, margin: "0 auto", padding: "32px 20px" }}>

{/* DASHBOARD */}
{tab === "dashboard" && (
<div style={{ animation: "fadeUp 0.4s ease" }}>
<div style={{ marginBottom: 32 }}>
<h1 style={{ fontSize: 36, fontWeight: "bold", margin: "0 0 8px", lineHeight: 1.1 }}>
Your Content<br /><span style={{ color: "#888", fontStyle: "italic" }}>makes money while you sleep.</span>
</h1>
<p style={{ color: "#666", maxWidth: 500, lineHeight: 1.7, fontSize: 15 }}>
Inkflow generates SEO-optimized articles in seconds. Publish them, monetize with ads, and watch passive income stack up — all while you're at work.
</p>
</div>

<div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))", gap: 16, marginBottom: 32 }}>
{[
{ label: "Revenue This Month", value: `$${revenue.toFixed(2)}`, sub: "+22% vs last month", color: "#a8e6cf" },
{ label: "Articles Published", value: "7", sub: "3 ranking on page 1", color: "#ffd3b6" },
{ label: "Avg. Monthly Visitors", value: "4,821", sub: "↑ 1,204 new this week", color: "#dcedc1" },
{ label: "Ad CTR", value: "3.8%", sub: "Industry avg: 2.1%", color: "#ffaaa5" },
].map((s) => (
<div key={s.label} style={{ background: "#fff", borderRadius: 12, padding: "20px 22px", border: "1.5px solid #e8e0d5", borderTop: `4px solid ${s.color}` }}>
<div style={{ fontSize: 11, color: "#999", textTransform: "uppercase", letterSpacing: 1, marginBottom: 6 }}>{s.label}</div>
<div style={{ fontSize: 28, fontWeight: "bold", marginBottom: 4 }}>{s.value}</div>
<div style={{ fontSize: 12, color: "#888" }}>{s.sub}</div>
</div>
))}
</div>

<div style={{ background: "#1a1a1a", borderRadius: 16, padding: "32px", color: "#f5f0e8", marginBottom: 32 }}>
<h2 style={{ margin: "0 0 24px", fontSize: 20, letterSpacing: 0.5 }}>How the passive income loop works</h2>
<div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(160px, 1fr))", gap: 20 }}>
{[
{ n: "01", title: "Pick a Niche", desc: "Choose a high-CPC topic. Finance and tech earn the most per click." },
{ n: "02", title: "Generate Articles", desc: "Claude writes SEO-optimized posts in seconds. 1,500–2,500 words each." },
{ n: "03", title: "Publish & Index", desc: "Post to WordPress or Ghost. Google indexes within 24–72 hours." },
{ n: "04", title: "Monetize", desc: "Run Google AdSense, Mediavine, or affiliate links. Money rolls in." },
].map((s) => (
<div key={s.n}>
<div style={{ fontSize: 32, color: "#555", fontWeight: "bold", marginBottom: 8 }}>{s.n}</div>
<div style={{ fontSize: 14, fontWeight: "bold", marginBottom: 6 }}>{s.title}</div>
<div style={{ fontSize: 12, color: "#aaa", lineHeight: 1.6 }}>{s.desc}</div>
</div>
))}
</div>
</div>

{/* Setup instructions */}
<div style={{ background: "#fffbf0", border: "1.5px solid #ffe082", borderRadius: 14, padding: "24px 28px", marginBottom: 28 }}>
<h3 style={{ margin: "0 0 16px", fontSize: 16 }}>🚀 Deploy in 5 minutes — Free</h3>
{[
{ step: "1", text: "Go to vercel.com and create a free account" },
{ step: "2", text: 'Create a new project and upload both files: the React app and api/proxy.js' },
{ step: "3", text: 'In Vercel dashboard → Settings → Environment Variables, add: ANTHROPIC_API_KEY = your key from console.anthropic.com' },
{ step: "4", text: 'Copy your deployed URL (e.g. https://inkflow.vercel.app) and paste it into the PROXY_URL constant at the top of the React file' },
{ step: "5", text: "Redeploy — article generation will work!" },
].map((s) => (
<div key={s.step} style={{ display: "flex", gap: 14, marginBottom: 10, alignItems: "flex-start" }}>
<span style={{ background: "#1a1a1a", color: "#fff", borderRadius: "50%", width: 22, height: 22, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 11, fontWeight: "bold", flexShrink: 0, marginTop: 1 }}>{s.step}</span>
<span style={{ fontSize: 14, color: "#444", lineHeight: 1.5 }}>{s.text}</span>
</div>
))}
</div>

<button onClick={() => setTab("generate")} style={{ padding: "14px 36px", background: "#1a1a1a", color: "#f5f0e8", border: "none", borderRadius: 10, fontSize: 15, cursor: "pointer", fontFamily: "inherit", fontWeight: "bold", letterSpacing: 0.5 }}>
✦ Start Generating Articles →
</button>
</div>
)}

{/* GENERATE */}
{tab === "generate" && (
<div style={{ animation: "fadeUp 0.4s ease" }}>
<h2 style={{ fontSize: 26, marginBottom: 6 }}>Generate Your Article</h2>
<p style={{ color: "#888", marginBottom: 24, fontSize: 14 }}>Pick a niche, enter a title (or use a suggestion), and let Claude do the writing.</p>

<div style={{ marginBottom: 24 }}>
<div style={{ fontSize: 12, color: "#888", textTransform: "uppercase", letterSpacing: 1, marginBottom: 10 }}>Select Niche</div>
<div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
{NICHES.map((n) => (
<button key={n.id} onClick={() => setSelectedNiche(n.id)}
style={{ padding: "8px 18px", borderRadius: 8, cursor: "pointer", fontSize: 13, border: selectedNiche === n.id ? "2px solid #1a1a1a" : "1.5px solid #d4c9b8", background: selectedNiche === n.id ? "#1a1a1a" : "#fdfaf7", color: selectedNiche === n.id ? "#fff" : "#555", fontFamily: "inherit" }}>
{n.emoji} {n.label} <span style={{ marginLeft: 8, fontSize: 11, opacity: 0.7 }}>CPC {n.cpc}</span>
</button>
))}
</div>
</div>

<div style={{ background: "#fff", borderRadius: 14, padding: "28px", border: "1.5px solid #e8e0d5" }}>
<ArticleGenerator niche={selectedNiche} />
</div>

<div style={{ marginTop: 20, padding: "14px 18px", background: "#fff8f0", borderRadius: 10, border: "1.5px solid #ffe0b2", fontSize: 13, color: "#c0540a" }}>
💡 <strong>Pro tip:</strong> Publish 3–5 articles/week consistently. Most sites hit $500+/mo within 6 months.
</div>
</div>
)}

{/* PRICING */}
{tab === "pricing" && (
<div style={{ animation: "fadeUp 0.4s ease" }}>
<h2 style={{ fontSize: 26, marginBottom: 6 }}>Simple Pricing</h2>
<p style={{ color: "#888", marginBottom: 30, fontSize: 14 }}>One article can earn back your subscription in days.</p>
<div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))", gap: 20 }}>
{PLANS.map((plan) => (
<div key={plan.name} style={{ background: plan.popular ? "#1a1a1a" : "#fff", color: plan.popular ? "#f5f0e8" : "#1a1a1a", borderRadius: 16, padding: "32px 28px", border: plan.popular ? "none" : "1.5px solid #e8e0d5", position: "relative" }}>
{plan.popular && <div style={{ position: "absolute", top: -12, left: "50%", transform: "translateX(-50%)", background: "#ffd3b6", color: "#1a1a1a", padding: "3px 14px", borderRadius: 20, fontSize: 11, fontWeight: "bold", letterSpacing: 1, textTransform: "uppercase", whiteSpace: "nowrap" }}>Most Popular</div>}
<div style={{ width: 40, height: 8, background: plan.color, borderRadius: 4, marginBottom: 20 }} />
<div style={{ fontSize: 18, fontWeight: "bold", marginBottom: 8 }}>{plan.name}</div>
<div style={{ fontSize: 36, fontWeight: "bold", marginBottom: 4 }}>${plan.price}<span style={{ fontSize: 14, fontWeight: "normal", opacity: 0.6 }}>/mo</span></div>
<div style={{ fontSize: 14, opacity: 0.7, marginBottom: 24 }}>{plan.articles} articles/month</div>
{[`${plan.articles} AI-generated articles`, "SEO keywords included", "Revenue estimates per article", "WordPress copy-paste ready", plan.name !== "Starter" ? "Priority generation" : "Standard queue"].map((f) => (
<div key={f} style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 8, fontSize: 13 }}>
<span style={{ color: plan.popular ? "#a8e6cf" : "#2e7d32" }}>✓</span> {f}
</div>
))}
<button style={{ marginTop: 24, width: "100%", padding: "12px 0", borderRadius: 8, border: "none", background: plan.popular ? "#f5f0e8" : "#1a1a1a", color: plan.popular ? "#1a1a1a" : "#f5f0e8", fontSize: 14, cursor: "pointer", fontFamily: "inherit", fontWeight: "bold" }}>
Get Started
</button>
</div>
))}
</div>
<div style={{ marginTop: 28, textAlign: "center", fontSize: 13, color: "#888" }}>
All plans include a 7-day free trial. Cancel anytime.
</div>
</div>
)}
</div>
</div>
);
}
