# FORK-ROADMAP — postiz-libre

> Living roadmap. Updated from `dev`. Priority: 🔴 high → 🟡 medium → 🟢 low.

## Now

| Task | Since |
|-------|-------|
| 🔴 Polish `feat/compose-improvements` for upstream PR | 2026-07-31 |

## Backlog

| Prio | Task | Ver | Blocked by | Who |
|:---:|------|:---:|---|:---:|
| 🔴 | PR `feat/compose-improvements` → upstream | — | Polish feat/compose | Human |
| 🔴 | PR `feat/unlock-ai-vendor-lockin` → upstream | — | Polish feat/unlock | Human |
| 🟡 | Multi-env: `docker-compose.test.yaml` + `ENV=test` | v2.23 | — | AI |
| 🟡 | Multi-env: test-specific seeding/health checks | v2.23 | test.yaml | AI |
| 🟢 | `.env.example` — document Docker vs host mode | v2.23 | — | AI |
| 🟢 | Fork-specific CODE_OF_CONDUCT.md + CONTRIBUTING.md | v2.23 | — | AI |
| 🟢 | Replace nginx with Ferron (auto Let's Encrypt) | v2.24 | feat/compose-improvements merged upstream | AI |

## Maintenance

| Task | Frequency | Who |
|------|-----------|-----|
| Sync upstream (fetch → rebase main → rebase dev → rebase feat/*) | Per release | Human |

## Done

- `v2.22.1-libre-6` — first stable release: Docker CI with semver floating tags, repo cleanup, rename, license fix (2026-07-31)

## Sync log

| Date | Upstream commit | Action |
|------|-----------------|--------|
| 2026-07-29 | `994b56c7` | Initial sync |
| 2026-07-31 | `cf4c432c` | Synced main, rebased dev + feat/*, merged feat/compose + feat/unlock |
