# Postiz Libre

Community fork breaking the OpenAI vendor lock-in. Use any backend — LocalAI,
Ollama, OpenRouter, Groq, Gemini, Anthropic, or your own.

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL%203.0-blue.svg)](LICENSE)
[![Docker image](https://img.shields.io/badge/Docker-ghcr.io/oopen/postiz--libre-2496ED)](https://github.com/oopen/postiz-libre/pkgs/container/postiz-libre)

> **Disclaimer:** This is an independent community fork of [Postiz](https://github.com/gitroomhq/postiz-app)
> by Gitroom. It is not affiliated with, endorsed by, or maintained by Gitroom Limited / Gitroom LLC.
> All trademarks, logos, and brand names belong to their respective owners.

## Why this fork?

→ [FORK-README.md](FORK-README.md) — full audit of upstream governance failures

## Usage TL;DR

### Production

In your `docker-compose.yaml` in service `postiz`

1. Add the AI environment variables `OPENAI_*`, `PORT: 3000`, `FRONTEND_PORT: 4200`

2. Replace the image tag by: `ghcr.io/oopen/postiz-libre:latest`

```yaml
services:
  postiz:
    # image: ghcr.io/gitroomhq/postiz-app:latest
    image: ghcr.io/oopen/postiz-libre:v2.22-libre
    restart: unless-stopped
    environment:
      FRONTEND_PORT: '4200'
      PORT: '3000'
      OPENAI_API_KEY: 'sk-...'
      OPENAI_BASE_URL: 'https://api.deepseek.com'
      OPENAI_MODEL: 'deepseek-v4-flash'
      OPENAI_CLASSIFIER_MODEL: 'deepseek-v4-flash'
      OPENAI_IMAGE_API_KEY: 'sk-or-v1-...'
      OPENAI_IMAGE_BASE_URL: 'https://openrouter.ai/api/v1'
      OPENAI_IMAGE_MODEL: 'black-forest-labs/flux.2-klein-4b'
      OPENAI_MAX_TOKENS: '8192'
      [...]
```

→ [docker-compose.yaml](docker-compose.yaml) — full reference

### Development

#### Prerequisites

Have `docker`, `docker-compose`, `just` installed on your host.

#### One time setup

```sh
gh repo clone oopen/postiz-libre
cd postiz-libre/
cp .env.example .env
```

Change your `OPENAI_API_KEY` and `OPENAI_IMAGE_API_KEY` with your own keys.

#### Start

```bash
just up
```

#### Wait until setup complete

Optional: follow the app logs in another terminal.

```bash
just app-logs
```

#### Open your full containerized services

```bash
just open
```

## Dev workflow

→ [FORK-GIT-WORKFLOW.md](FORK-GIT-WORKFLOW.md) — setup, branches, sync, and release

## Changelog

→ [FORK-CHANGELOG.md](FORK-CHANGELOG.md)

## Roadmap

→ [FORK-ROADMAP.md](FORK-ROADMAP.md)

## Contributing

→ [CONTRIBUTING.md](CONTRIBUTING.md)

## Screenshot

![Postiz Libre unlock LLM](postiz-libre-alive.avif)
