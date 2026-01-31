export function getEnv(name: string, required = true): string {
  const value = Deno.env.get(name);
  if (required && (!value || value.trim().length === 0)) {
    throw new Error(`Missing env var: ${name}`);
  }
  return value ?? "";
}
