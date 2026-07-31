# FORK-ROADMAP — postiz-libre

> Living roadmap. Updated from `dev`. Priority: 🔴 high → 🟡 medium → 🟢 low.

## Now

| Task | Since |
|-------|-------|
| 🔴 Polish `feat/compose-improvements` for upstream PR | 2026-07-31 |

## Backlog

| Prio | Task | Ver |
|:---:|------|:---:|
| 🔴 | PR `feat/compose-improvements` → upstream | — |
| 🔴 | PR `feat/unlock-ai-vendor-lockin` → upstream | — |
| 🟡 | Multi-env: `docker-compose.test.yaml` + `ENV=test` | v2.23 |
| 🟡 | Multi-env: test-specific seeding/health checks | v2.23 |
| 🟢 | `.env.example` — document Docker vs host mode | v2.23 |
| 🟢 | Fork-specific CODE_OF_CONDUCT.md + CONTRIBUTING.md | v2.23 |
| 🟢 | Replace nginx with Ferron (auto Let's Encrypt) | v2.24 |

## Maintenance

| Task | Frequency |
|------|-----------|
| Sync upstream (fetch → rebase main → rebase dev → rebase feat/*) | Per release |

## Done

- `v2.22.1-libre` — first stable release: Docker CI with semver floating tags, repo cleanup, rename, license fix (2026-07-31)

## Sync log

| Date | Upstream commit | Action |
|------|-----------------|--------|
| 2026-07-29 | `994b56c7` | Initial sync |
| 2026-07-31 | `cf4c432c` | Synced main, rebased dev + feat/*, merged feat/compose + feat/unlock |
