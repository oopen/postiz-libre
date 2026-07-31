# FORK-ROADMAP — postiz-libre

> Living roadmap. Updated from `dev`. Priority: 🔴 high → 🟡 medium → 🟢 low.

## Now

| Tâche | Depuis |
|-------|--------|
| 🔴 Polish `feat/compose-improvements` for upstream PR | 2026-07-31 |

## Backlog

| Prio | Tâche | Ver | Bloqué par | Qui |
|:---:|-------|:---:|---|:---:|
| 🔴 | Sync upstream (fetch → rebase main → rebase dev → rebase feat/*) | — | — | Human |
| 🔴 | PR `feat/compose-improvements` → `gitroomhq/postiz-app:main` | — | Upstream sync | Human |
| 🔴 | PR `feat/unlock-ai-vendor-lockin` → upstream | — | Upstream sync | Human |
| 🟡 | Multi-env: `docker-compose.test.yaml` + `ENV=test` | v0.2 | — | AI |
| 🟡 | Multi-env: test-specific seeding/health checks | v0.2 | test.yaml | AI |
| 🟢 | `.env.example` — document Docker vs host mode | v0.2 | — | AI |
| 🟢 | Fork-specific CODE_OF_CONDUCT.md + CONTRIBUTING.md | v0.2 | — | AI |
| 🟢 | Replace nginx with Ferron (auto Let's Encrypt) | v0.3 | Working Docker build | AI |

## Done

- `v2.22.1-libre` — first Postiz Libre release: Docker CI, repo cleanup, AI unlock, compose (2026-07-31)

## Sync log

| Date | Upstream commit | Action |
|------|-----------------|--------|
| 2026-07-29 | `994b56c7` | Initial sync |
