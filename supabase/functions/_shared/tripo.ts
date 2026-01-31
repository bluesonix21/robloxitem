import { getEnv } from "./env.ts";

const BASE_URL = "https://api.tripo3d.ai/v2/openapi/task";

export type TripoStatus =
  | "queued"
  | "running"
  | "success"
  | "failed"
  | "banned"
  | "expired"
  | "cancelled"
  | "unknown";

export interface TripoTask {
  task_id: string;
  type?: string;
  status?: TripoStatus;
  input?: Record<string, unknown>;
  output?: Record<string, unknown>;
  progress?: number;
  create_time?: number;
  [key: string]: unknown;
}

function authHeaders(apiKey?: string) {
  return {
    Authorization: `Bearer ${apiKey ?? getEnv("TRIPO_API_KEY")}`,
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
      : `Tripo request failed: ${response.status}`;
    throw new Error(message);
  }
  return json as Record<string, unknown>;
}

export async function createTripoTask(
  payload: Record<string, unknown>,
  apiKey?: string
): Promise<string> {
  const data = await fetchJson(BASE_URL, {
    method: "POST",
    headers: authHeaders(apiKey),
    body: JSON.stringify(payload)
  });
  const taskId = (data.data as Record<string, unknown> | undefined)?.task_id;
  if (!taskId || typeof taskId !== "string") {
    throw new Error("Tripo response missing task_id");
  }
  return taskId;
}

export async function getTripoTask(taskId: string, apiKey?: string): Promise<TripoTask> {
  const data = await fetchJson(`${BASE_URL}/${taskId}`, {
    method: "GET",
    headers: authHeaders(apiKey)
  });
  const task = (data.data as Record<string, unknown> | undefined) ?? {};
  return task as TripoTask;
}
