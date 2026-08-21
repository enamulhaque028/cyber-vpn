# Docs index (start here)

This folder is the source of truth for **Cyber VPN** (`/Users/sabrinaakter/development/flutter/cyber-vpn`).

| File | Use |
|------|-----|
| [STATUS.md](STATUS.md) | What is built vs not, **what to do next**, protection-layer behavior |
| [FEATURES.md](FEATURES.md) | **Shipped features** + enrichment roadmap + [split tunnel](FEATURES.md#split-tunnel--per-app-vpn) |
| [ARCHITECTURE.md](ARCHITECTURE.md) | How the code is laid out; conventions for agents |
| [FLEET_CATALOG.md](FLEET_CATALOG.md) | Locations control plane: GitHub catalog + jsDelivr; migration details + **your next steps** |
| [PROJECT_PLAN.md](PROJECT_PLAN.md) | Full product spec (goals, monetization, MVP vs V1 vs V2, what not to copy from Turbo Secure) |

**If you are an AI agent in a new chat:** read `STATUS.md`, then `ARCHITECTURE.md`. Use `PROJECT_PLAN.md` §10 for the roadmap and §6 for revenue. Do not implement V2 fleet/WireGuard unless the user asks. Do not copy Turbo Secure’s TLS bypass, UXCam, or fake tab bar.

Repo root `README.md` is run/iOS/Android setup only.
