import { corsHeaders } from "./cors.ts";

export function jsonResponse(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json"
    }
  });
}

export function errorResponse(message: string, status = 400, extra?: Record<string, unknown>): Response {
  return jsonResponse({ error: message, ...extra }, status);
}
