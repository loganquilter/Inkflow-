// api/proxy.js — Vercel Edge Function
// Deploy this to Vercel. It forwards requests to Anthropic so your
// browser app never calls Anthropic directly (which gets blocked).

export const config = { runtime: "edge" };

export default async function handler(req) {
// Allow requests from your deployed frontend domain.
// Change "*" to your actual domain in production, e.g. "https://inkflow.vercel.app"
const corsHeaders = {
"Access-Control-Allow-Origin": "*",
"Access-Control-Allow-Methods": "POST, OPTIONS",
"Access-Control-Allow-Headers": "Content-Type",
};

// Handle preflight
if (req.method === "OPTIONS") {
return new Response(null, { status: 204, headers: corsHeaders });
}

if (req.method !== "POST") {
return new Response("Method not allowed", { status: 405, headers: corsHeaders });
}

try {
const body = await req.json();

const anthropicRes = await fetch("https://api.anthropic.com/v1/messages", {
method: "POST",
headers: {
"Content-Type": "application/json",
"x-api-key": process.env.ANTHROPIC_API_KEY, // Set this in Vercel dashboard
"anthropic-version": "2023-06-01",
},
body: JSON.stringify(body),
});

const data = await anthropicRes.json();
return new Response(JSON.stringify(data), {
status: anthropicRes.status,
headers: { ...corsHeaders, "Content-Type": "application/json" },
});
} catch (err) {
return new Response(JSON.stringify({ error: err.message }), {
status: 500,
headers: { ...corsHeaders, "Content-Type": "application/json" },
});
}
}
