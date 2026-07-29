# Changelog — postiz-app-libre

All notable changes to postiz-app-libre will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versions are tagged `vX.Y.Z-libre` from the `dev` branch.

---

## [Unreleased]

## [v0.1.0-libre] — 2026-07-29

### Added

- **feat(unlock-ai-vendor-lockin):** configurable OpenAI baseURL and model via environment variables.
  Supports any OpenAI-compatible backend (OpenRouter, Ollama, Groq, Local-AI, etc.).
  - 9 new env vars: `OPENAI_BASE_URL`, `OPENAI_MODEL`, `OPENAI_IMAGE_BASE_URL`, `OPENAI_IMAGE_MODEL`,
    `OPENAI_IMAGE_API_KEY`, `OPENAI_CLASSIFIER_BASE_URL`, `OPENAI_CLASSIFIER_MODEL`,
    `OPENAI_CLASSIFIER_API_KEY`, `OPENAI_MAX_TOKENS`.
  - Provider-agnostic error handling with `mapApiError()` and regex extraction.
  - Retry logic for 429 rate-limit errors via `createRetryableClient()`.
  - Inline error banners in agent chat with i18n keys.
  - Agent image display: `AgentRenderMessage` renders `ResultMessage` inline.
  (Commit `496bf78a`, 15 files, +581/−39)

- **feat(compose-improvements):** configurable frontend/backend ports via `.env`,
  justfile task runner, dynamic Docker ports.
  - `PORT` and `FRONTEND_PORT` in `.env` (single source of truth).
  - `apps/frontend/package.json` reads `$FRONTEND_PORT` instead of hardcoded `4200`.
  - `docker-compose.dev.yaml` uses dynamic ports (`127.0.0.1:0`).
  - `justfile` for Docker lifecycle (up/stop/restart/reset/purge/ports/health).
  (Commit `790ea264`, 4 files, +313/−12)

### Documentation

- `FORK-README.md`: comprehensive audit of upstream governance failures
- `FORK-GOVERNANCE.md`: 8 ignored issues, 4 blocked PRs, deleted comments, governance analysis
- `FORK-GIT-WORKFLOW.md`: branch management and sync workflow guide
- `FORK-CHANGELOG.md`: this file

[Unreleased]: https://github.com/oopen/postiz-app-libre/compare/v0.1.0-libre...dev
[v0.1.0-libre]: https://github.com/oopen/postiz-app-libre/releases/tag/v0.1.0-libre
