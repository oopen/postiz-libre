# Changelog — postiz-libre

All notable changes to postiz-libre will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions are tagged `vX.Y.Z-libre` from the `dev` branch.

---

## [v2.22.1-libre] — 2026-07-31

### Added

- **feat(unlock-ai-vendor-lockin):** configurable OpenAI backends
  - 9 new env vars: `OPENAI_BASE_URL`, `OPENAI_MODEL`, `OPENAI_IMAGE_*`, `OPENAI_CLASSIFIER_*`, `OPENAI_MAX_TOKENS`
  - Retry logic for 429 rate-limit, provider-agnostic error handling
  - Inline error banners in agent chat with i18n keys
  - (Commit `496bf78a`, 15 files, +581/−39)

- **feat(compose):** containerized dev, multi-stage Dockerfile, health endpoints
  - `Dockerfile.dev`: 4 stages (base, prod, dev, build)
  - `docker-compose.dev.yaml`: split backend/frontend, dynamic ports
  - `justfile`: task runner (up/stop/restart/reset/purge, health checks, port discovery)
  - Health endpoints: backend `/` (DB, Redis, Temporal), frontend `/api/health`

- **feat(ci):** Docker build workflow + GHCR image push
  - `.github/workflows/docker-build.yml`: builds prod stage on push to dev, tags, manual dispatch
  - Image published to `ghcr.io/oopen/postiz-libre` (tags: `latest`, `dev`, `dev-{sha}`)
  - `Dockerfile.dev`: `--frozen-lockfile` for reproducible builds
  - `.github/Dependabot.yml`: weekly npm updates targeting dev

### Changed

- **chore:** repository cleanup
  - Removed 23 upstream governance/CI/files (CCLA, ICLA, CoC, SECURITY, CONTRIBUTING, CLAUDE.md, workflows, templates, assets)
  - Renamed repository from `postiz-app-libre` to `postiz-libre`
  - Renamed `FORK-TODO.md` → `FORK-ROADMAP.md` with updated content
  - Fixed license references from MIT to AGPL-3.0 in `FORK-README.md`
  - Added fork-specific `README.md` with legal disclaimer and env var example

### Fixed

- **fix:** 502 Bad Gateway in Docker image
  - Restored upstream `var/docker/nginx.conf` (missing proxy headers, `/uploads/` location block)
  - Added `PORT` and `FRONTEND_PORT` to `docker-compose.yaml`

### Documentation

- `FORK-README.md`: comprehensive audit of upstream governance failures
- `FORK-GIT-WORKFLOW.md`: branch management and sync workflow guide
- `FORK-CHANGELOG.md`: this file

[v2.22.1-libre]: https://github.com/oopen/postiz-libre/releases/tag/v2.22.1-libre
