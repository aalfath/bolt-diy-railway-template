#!/bin/bash
# Starts bolt.diy on 127.0.0.1:5173 and Caddy on $PORT in front of it.
set -euo pipefail

export PORT="${PORT:-8080}"
export BOLT_USERNAME="${BOLT_USERNAME:-admin}"

if [ -z "${BOLT_PASSWORD:-}" ]; then
  echo "BOLT_PASSWORD is not set. Set it to protect bolt.diy with a login." >&2
  exit 1
fi
if [ "$PORT" = "5173" ]; then
  echo "PORT 5173 is used by bolt.diy itself. Use another PORT (default 8080)." >&2
  exit 1
fi

BOLT_PASSWORD_HASH="$(caddy hash-password --plaintext "$BOLT_PASSWORD")"
export BOLT_PASSWORD_HASH
unset BOLT_PASSWORD
export XDG_CONFIG_HOME=/tmp/caddy/config XDG_DATA_HOME=/tmp/caddy/data

# bolt.diy's server (Cloudflare workerd under `vite preview`) reads its settings
# from build/server/.dev.vars, not from the container environment. Copy LLM
# provider keys and settings set as Railway variables into that file.
cd /app
node -e '
const fs = require("fs");
const re = /(_API_KEY|_API_TOKEN|_API_BASE_URL|_BASE_URL|_API_MODELS)$|^(AWS_BEDROCK_CONFIG|DEFAULT_NUM_CTX|VITE_LOG_LEVEL)$/;
const lines = [];
for (const [k, v] of Object.entries(process.env)) {
  if (!re.test(k) || k.startsWith("RAILWAY_") || v === "") continue;
  const q = !v.includes("\x27") ? "\x27" : !v.includes("`") ? "`" : "\"";
  lines.push(`${k}=${q}${v}${q}`);
}
fs.writeFileSync("build/server/.dev.vars", lines.join("\n") + "\n", { mode: 0o600 });
console.log(`bolt.diy: passed ${lines.length} setting(s) to the server: ${lines.map(l => l.split("=")[0]).join(", ") || "none"}`);
'

pnpm run dockerstart &
caddy run --config /etc/bolt/Caddyfile --adapter caddyfile &

trap 'kill $(jobs -p) 2>/dev/null; exit 0' TERM INT
# Stop the container when either process exits, so Railway restarts it.
wait -n
exit 1
