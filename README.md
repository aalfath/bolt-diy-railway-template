[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/boltdiy-1?utm_medium=integration&utm_source=button&utm_campaign=bolt-diy)

# bolt.diy on Railway

Railway template for [bolt.diy](https://github.com/stackblitz-labs/bolt.diy), the open-source AI app builder: describe an app in a prompt and bolt.diy writes, runs and edits a full-stack web app in your browser, using the LLM provider of your choice.

This repo deploys **bolt.diy v1.0.3** from the official image `ghcr.io/stackblitz-labs/bolt.diy:v1.0.3`, pinned by digest, with a small [Caddy](https://caddyserver.com) proxy in front that adds a login.

## What the template deploys

One service, built from this repo's `Dockerfile`:

- bolt.diy's production server (`vite preview`) on `127.0.0.1:5173`, inside the container only.
- Caddy on `PORT` (8080), the only public port. It asks for a username and password (HTTP basic auth) before anything reaches bolt.diy, because bolt.diy has no login of its own. `/healthz` answers without a login, for Railway's health check.

bolt.diy keeps chats, projects and settings in the browser (IndexedDB and cookies), not on the server, so the service needs no volume. Back up or move your work with bolt.diy's own export and GitHub features.

## Variables

| Variable | Default | What it does |
|---|---|---|
| `BOLT_USERNAME` | `admin` | Login username. |
| `BOLT_PASSWORD` | generated (`${{secret(24)}}`) | Login password. Find it in the service's Variables tab. |
| `PORT` | `8080` | Port Caddy listens on. Don't use 5173. |

**LLM keys (optional).** You can enter API keys in bolt.diy's settings, where they're stored in your browser. To set them once for everyone who logs in, add them as service variables instead, for example `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GOOGLE_GENERATIVE_AI_API_KEY`, `OPEN_ROUTER_API_KEY`, `GROQ_API_KEY`, `OLLAMA_API_BASE_URL` or `AWS_BEDROCK_CONFIG` (names as in upstream's [`.env.example`](https://github.com/stackblitz-labs/bolt.diy/blob/main/.env.example)). The start script passes every variable ending in `_API_KEY`, `_API_TOKEN`, `_API_BASE_URL`, `_BASE_URL` or `_API_MODELS`, plus `AWS_BEDROCK_CONFIG`, `DEFAULT_NUM_CTX` and `VITE_LOG_LEVEL`, to bolt.diy's server.

## Updates

Railway tells everyone who deployed this template when this repo's `main` branch changes, and each deployer chooses when to apply it. Each update bumps the pinned image and is listed in [`CHANGELOG.md`](CHANGELOG.md), with breaking changes first.

## Files

- `Dockerfile`: the pinned bolt.diy image plus the Caddy binary.
- `Caddyfile`: the login and `/healthz`.
- `start.sh`: hashes the password, writes the LLM settings for bolt.diy's server, and starts both processes.

## License

The wrapper files in this repo are MIT. bolt.diy is MIT-licensed by StackBlitz and its contributors.
