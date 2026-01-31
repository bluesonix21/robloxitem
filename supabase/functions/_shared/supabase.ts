import { createClient } from "@supabase/supabase-js";
import { getEnv } from "./env.ts";

export function createAdminClient() {
  return createClient(getEnv("SUPABASE_URL"), getEnv("SUPABASE_SERVICE_ROLE_KEY"), {
    auth: { persistSession: false },
    global: {
      headers: {
        "X-Client-Info": "robloxitem-meshy-backend"
      }
    }
  });
}

export function createUserClient(authHeader: string | null) {
  return createClient(getEnv("SUPABASE_URL"), getEnv("SUPABASE_ANON_KEY"), {
    auth: { persistSession: false },
    global: {
      headers: {
        Authorization: authHeader ?? ""
      }
    }
  });
}
