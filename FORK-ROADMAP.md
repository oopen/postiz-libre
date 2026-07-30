# FORK-ROADMAP — postiz-app-libre

> Living roadmap. Updated from `dev`. Priority: 🔴 high → 🟡 medium → 🟢 low.

## Now

| Tâche | Depuis |
|-------|--------|
| 🔴 Clean repo: remove 20+ upstream files, rename TODO→ROADMAP, fix license docs | 2026-07-30 |

## Backlog

| Prio | Tâche | Ver | Bloqué par | Qui |
|:---:|-------|:---:|---|:---:|
| 🔴 | Sync upstream (fetch → rebase main → rebase dev → rebase feat/*) | — | — | Human |
| 🔴 | PR `feat/compose-improvements` → `gitroomhq/postiz-app:main` | — | Upstream sync | Human |
| 🟡 | Tag `v0.2.0-libre` | v0.2 | Docs updated | Human |
| 🟡 | Multi-env: `docker-compose.test.yaml` + `ENV=test` | v0.3 | — | AI |
| 🟡 | Multi-env: test-specific seeding/health checks | v0.3 | test.yaml | AI |
| 🟢 | `.env.example` — document Docker vs host mode | v0.3 | — | AI |
| 🟢 | PR `feat/unlock-ai-vendor-lockin` → upstream | — | Upstream sync | Human |
| 🟢 | Fork-specific CODE_OF_CONDUCT.md + CONTRIBUTING.md | v0.3 | — | AI |

## Done

- `feat/compose-improvements` — final review + repo cleanup (2026-07-30)
- `v0.1.0-libre` — AI vendor lock-in unlocked + compose improvements (2026-07-29)

## Sync log

| Date | Upstream commit | Action |
|------|-----------------|--------|
| 2026-07-29 | `994b56c7` | Initial sync |
