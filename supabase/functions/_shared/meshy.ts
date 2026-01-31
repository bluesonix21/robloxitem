import { getEnv } from "./env.ts";

const BASE_URL = "https://api.meshy.ai";
const TEXT_TO_3D_URL = `${BASE_URL}/v2/text-to-3d`;
const REMESH_URL = `${BASE_URL}/v1/remesh`;

export type MeshyStatus = "PENDING" | "IN_PROGRESS" | "SUCCEEDED" | "FAILED";

export interface MeshyTask {
  id: string;
  status: MeshyStatus;
  message?: string;
  model_urls?: Record<string, string>;
  texture_urls?: Record<string, string>;
  [key: string]: unknown;
}

function authHeaders(apiKey?: string | null) {
  const resolvedKey = apiKey ?? getEnv("MESHY_API_KEY");
  return {
    Authorization: `Bearer ${resolvedKey}`,
    "Content-Type": "application/json"
  };
}

async function fetchJson(url: string, options: RequestInit) {
  const response = await fetch(url, options);
  const text = await response.text();
  let json: unknown = {};
  if (text) {
    try {
      json = JSON.parse(text);
    } catch (_err) {
      json = { raw: text };
    }
  }
  if (!response.ok) {
    const message = typeof json === "object" && json !== null && "message" in json
      ? String((json as Record<string, unknown>).message)
      : `Meshy request failed: ${response.status}`;
    throw new Error(message);
  }
  return json as Record<string, unknown>;
}

export async function createTextTo3DTask(
  payload: Record<string, unknown>,
  apiKey?: string | null
): Promise<string> {
  const data = await fetchJson(TEXT_TO_3D_URL, {
    method: "POST",
    headers: authHeaders(apiKey),
    body: JSON.stringify(payload)
  });
  const result = data.result;
  if (!result || typeof result !== "string") {
    throw new Error("Meshy response missing result task id");
  }
  return result;
}

export async function getTextTo3DTask(taskId: string, apiKey?: string | null): Promise<MeshyTask> {
  const data = await fetchJson(`${TEXT_TO_3D_URL}/${taskId}`, {
    method: "GET",
    headers: authHeaders(apiKey)
  });
  return data as MeshyTask;
}

export async function createRemeshTask(
  payload: Record<string, unknown>,
  apiKey?: string | null
): Promise<string> {
  const data = await fetchJson(REMESH_URL, {
    method: "POST",
    headers: authHeaders(apiKey),
    body: JSON.stringify(payload)
  });
  const result = data.result;
  if (!result || typeof result !== "string") {
    throw new Error("Meshy remesh response missing result task id");
  }
  return result;
}

export async function getRemeshTask(taskId: string, apiKey?: string | null): Promise<MeshyTask> {
  const data = await fetchJson(`${REMESH_URL}/${taskId}`, {
    method: "GET",
    headers: authHeaders(apiKey)
  });
  return data as MeshyTask;
}
