# ═══════════════════════════════════════════════════════════════════════════════
# AI AGENT SAFETY RULES — DO NOT REMOVE
# ═══════════════════════════════════════════════════════════════════════════════
# NEVER execute:  git add, git commit, git merge, git push, just git-push
# NEVER execute:  git branch -D, git reset --hard, git clean -fd
# NEVER execute:  just purge, just reset without EXPLICIT user confirmation
# NEVER delete:   files, branches, tags without EXPLICIT user confirmation
# AI agents MUST: present diffs, suggest commit messages, STOP after coding
# The USER always: reviews code, stages, commits, and pushes personally
# ═══════════════════════════════════════════════════════════════════════════════

# Define precise web services that require http:// or https:// routing.
# Format: "service_name:internal_port" (space-separated)
WEB_SERVICES := "temporal-ui:8080 postiz-pg-admin:80 postiz-redisinsight:5540 postiz-frontend:4200 postiz-backend:3000 ferron:80"

# ==============================================================================
# Configuration & Environment Detection
# ==============================================================================

RAW_ENV := env_var_or_default("ENV", "dev")
ENV     := lowercase(RAW_ENV)

export COMPOSE_FILE := \
  if ENV == "prod" { \
    "compose.prod.yml" \
  } else if ENV == "test" { \
    "compose.test.yml" \
  } else { \
    "compose.dev.yml" \
  }

export FERRON_CONFIG := \
  if ENV == "prod" { \
    "./ferron/prod.kdl" \
  } else if ENV == "test" { \
    "./ferron/test.kdl" \
  } else { \
    "./ferron/dev.kdl" \
  }

set positional-arguments := true

# ==============================================================================
# Recipes (Commands)
# ==============================================================================

# List available commands, environment status, and filtering usage
default:
	#!/usr/bin/env bash
	just --list
	echo -e "\x1b[1m\n── Lifecycle ───────────────────────────────────────────────\x1b[0m"
	echo -e "  \x1b[32m🟢  up\x1b[0m                       # Start dev stack"
	echo -e "  \x1b[32m⏸️   stop\x1b[0m                     # Pause all containers"
	echo -e "  \x1b[32m🔄  restart\x1b[0m                  # Stop + start"
	echo -e "  \x1b[32m♻️   rebuild\x1b[0m                  # Force full rebuild"
	echo -e "  \x1b[31m💣  reset\x1b[0m                    # Nuke volumes + restart"
	echo -e "  \x1b[31m🔥  purge\x1b[0m                    # Nuke everything + images"
	echo -e "  \x1b[36m🔍  is-purged\x1b[0m                # Check for leftovers"
	echo -e "\x1b[1m\n── Monitoring ──────────────────────────────────────────────\x1b[0m"
	echo -e "  \x1b[36m📊  stats\x1b[0m                    # Docker CPU / RAM usage"
	echo -e "  \x1b[36m🗺️   ports\x1b[0m                    # Service port map"
	echo -e "  \x1b[36m🌐  open\x1b[0m                     # Start + open in browser"
	echo -e "  \x1b[36m🔌  check-ports\x1b[0m              # TCP connectivity check"
	echo -e "  \x1b[36m🔎  ports-query\x1b[0m              # Port bindings (scriptable)"
	echo -e "\x1b[1m\n── App ──────────────────────────────────────────────────────\x1b[0m"
	echo -e "  \x1b[32m📜  app-logs\x1b[0m                 # Tail backend + frontend"
	echo -e "  \x1b[32m❤️   app-backend-health\x1b[0m       # Backend: DB / Redis / Temporal"
	echo -e "  \x1b[32m❤️   app-frontend-health\x1b[0m      # Frontend + backend status"
	echo -e "  \x1b[33m🔧  app-build\x1b[0m                # Production build"
	echo -e "  \x1b[33m🧹  app-build-purge\x1b[0m          # Clean build volumes"
	echo -e "\x1b[1m\n── Git ──────────────────────────────────────────────────────\x1b[0m"
	echo -e "  \x1b[33m🏷️   git-tag\x1b[0m                  # List libre tags"
	echo -e "  \x1b[33m🏷️   git-tag-next\x1b[0m             # Compute next tag"
	echo -e "  \x1b[33m📌  git-tag-create\x1b[0m           # Create annotated tag"
	echo -e "  \x1b[31m🚀  git-push [branch]\x1b[0m         # Build + push + tags"
	echo -e "\x1b[1m\n── Config ──────────────────────────────────────────────────\x1b[0m"
	echo -e "  \x1b[35mENV=dev\x1b[0m     (default)         # Hot-reload, source mounts"
	echo -e "  \x1b[35mENV=prod\x1b[0m                      # GHCR images, auto-restart"
	echo -e "  \x1b[35mENV=test\x1b[0m                      # Minimal limits"
	echo -e "  \x1b[35mFERRON_DOMAIN=*\x1b[0m              # Behind reverse proxy"
	echo -e "  \x1b[35mFERRON_DOMAIN=example.com\x1b[0m    # Let's Encrypt auto-TLS"
	echo ""
	echo -e "  \x1b[1m⚙️   {{ ENV }} | {{ COMPOSE_FILE }} | FERRON: {{ FERRON_CONFIG }}\x1b[0m"
	echo ""

# Wrapper to execute any native docker compose command within the detected environment
compose *args:
	@docker compose {{ args }}

# Start all services: infra + backend, discover port, then frontend
up:
	#!/usr/bin/env bash
	set -euo pipefail
	just compose --profile frontend stop postiz-frontend 2>/dev/null || true
	echo "🚀 Starting infrastructure + backend..."
	just compose up -d --remove-orphans
	echo "⏳ Waiting for backend health..."
	until just app-backend-health > /dev/null 2>&1; do sleep 2; done
	BACKEND_PORT=$(just compose port postiz-backend 3000 | cut -d: -f2)
	mkdir -p apps/frontend
	echo "NEXT_PUBLIC_BACKEND_URL=http://localhost:$BACKEND_PORT" > apps/frontend/.env.local
	echo "NODE_OPTIONS=--max-old-space-size=4096" >> apps/frontend/.env.local
	echo "✅ Backend ready at localhost:$BACKEND_PORT"
	echo "🚀 Starting frontend..."
	just compose --profile frontend up -d --remove-orphans
	echo "⏳ Waiting for frontend health..."
	until just app-frontend-health > /dev/null 2>&1; do sleep 2; done
	FRONTEND_PORT=$(just compose port postiz-frontend 4200 | cut -d: -f2)
	echo "✅ Frontend ready at localhost:$FRONTEND_PORT"
	just ports
	just check-ports

# Force download, rebuild, and recreate the entire stack
rebuild:
	just compose --profile frontend up -d --remove-orphans --pull always --build --force-recreate --renew-anon-volumes
	just ports
	just check-ports

# Stop containers without removing them
stop:
	just compose --profile '"*"' stop

# Tail the app server logs
app-logs:
	just compose logs -f postiz-backend postiz-frontend

# Live container resource usage (CPU / RAM)
stats:
	just compose stats --no-stream

# Check backend application health (DB, Redis, Temporal)
app-backend-health:
	#!/usr/bin/env bash
	set -euo pipefail
	BACKEND_PORT=$(just compose port postiz-backend 3000 2>/dev/null | cut -d: -f2)
	if [ -z "${BACKEND_PORT:-}" ]; then echo "❌ Backend is not running"; exit 1; fi
	curl -s "http://localhost:$BACKEND_PORT/health" || { echo "❌ Backend not responding"; exit 1; }

# Check frontend application health (includes backend status)
app-frontend-health:
	#!/usr/bin/env bash
	set -euo pipefail
	FRONTEND_PORT=$(just compose port postiz-frontend 4200 2>/dev/null | cut -d: -f2)
	if [ -z "${FRONTEND_PORT:-}" ]; then echo "❌ Frontend is not running"; exit 1; fi
	curl -s "http://localhost:$FRONTEND_PORT/health" || { echo "❌ Frontend not responding"; exit 1; }

# Fast and safe reboot of the stack without data loss
restart: stop up

# Stop and remove all containers, networks, and database volumes, then fresh start
reset:
	just compose --profile '"*"' down --remove-orphans --volumes
	just is-purged || true
	just up

# Deep clean this local Docker stack
purge:
	#!/usr/bin/env bash
	set -euo pipefail
	YELLOW="\x1b[33m"; RESET="\x1b[0m"; BOLD="\x1b[1m"
	echo -e "${YELLOW}⚠️  Warning: This will destroy this stack's containers, persistent data volumes, and locally built images.${RESET}"
	echo -e "${YELLOW}Official images (Postgres, Redis, etc.) and other Docker stacks will NOT be affected.${RESET}"
	read -p "Are you sure you want to proceed? (y/N)  " -n 1 -r
	echo ""
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		echo "Purge aborted."
		exit 0
	fi
	echo "🧹 Destroying stack containers, volumes, and locally built images..."
	just compose --profile '"*"' down --remove-orphans --volumes --rmi local
	PROJECT=$(just _project-name); docker volume ls -q --filter name="${PROJECT}_" 2>/dev/null | while read -r vol; do docker volume rm -f "$vol" > /dev/null 2>&1 || true; done
	echo -e "✨ ${BOLD}Stack successfully purged!${RESET}"

# Parse 'docker compose ps' output to extract real host ports with colorized UI
ports:
	#!/usr/bin/env bash
	set -euo pipefail
	CYAN="\x1b[36m"; GREEN="\x1b[32m"; YELLOW="\x1b[33m"; RED="\x1b[31m"; RESET="\x1b[0m"; BOLD="\x1b[1m"
	echo ""
	echo "🗺️  Service Port Map (Env: {{ ENV }})"
	echo "─────────────────────────────────────────────────────────────────"
	just _query all | while IFS='|' read -r is_active state svc url internal layer_proto; do
		status_icon="🟢"
		if [[ "$state" =~ exited|dead ]]; then status_icon="🔴"; fi
		if [[ "$state" =~ restarting|paused ]]; then status_icon="🟡"; fi
		printf "  %s  %-20s %b→%b  %b%-30s%b %b(container: %s/%s)%b\n" \
			"$status_icon" "$svc" "$CYAN" "$RESET" "$BOLD$GREEN" "$url" "$RESET" "$YELLOW" "$internal" "$layer_proto" "$RESET"
	done
	echo "─────────────────────────────────────────────────────────────────"

# Open discovered web services in your browser
open target="all":
	#!/usr/bin/env bash
	set -euo pipefail
	if command -v xdg-open >/dev/null; then OPEN_CMD="xdg-open"
	elif command -v open >/dev/null; then OPEN_CMD="open"
	elif command -v cmd.exe >/dev/null; then OPEN_CMD="cmd.exe /c start"
	else
		echo "❌ Error: No browser opener command found." >&2; exit 1
	fi
	if [ "{{ target }}" = "all" ]; then
		echo "🚀 Ensuring the whole stack is up..."
		just compose --profile frontend up -d --remove-orphans
		just ports
		just check-ports
	else
		echo "🚀 Ensuring service '{{ target }}' is up..."
		just compose up -d --remove-orphans "{{ target }}"
		sleep 1
	fi
	filter_mode="web"
	if [ "{{ target }}" != "all" ]; then filter_mode="all"; fi
	just _query "$filter_mode" | while IFS='|' read -r is_active state svc url internal layer_proto; do
		if [ "{{ target }}" != "all" ] && [ "$svc" != "{{ target }}" ]; then continue; fi
		if [ "$is_active" -ne 1 ]; then
			echo "⚠️  Skipping $svc (Container is not running: $state)"
			continue
		fi
		host_port="${url##*:}"
		if [[ "${seen_ports:-}" == *",$host_port,"* ]]; then continue; fi
		seen_ports="${seen_ports:-},$host_port,"
		echo "🔗 Opening $svc → $url ..."
		$OPEN_CMD "$url"
	done

# Check TCP port connectivity for all published services
check-ports:
	#!/usr/bin/env bash
	set -euo pipefail
	GREEN="\x1b[32m"; RED="\x1b[31m"; RESET="\x1b[0m"; BOLD="\x1b[1m"
	failed=0
	count=0
	echo ""
	echo "🧪 Running Stack Healthchecks..."
	echo "─────────────────────────────────────────────────────────────────"
	while IFS='|' read -r is_active state svc url internal layer_proto; do
		[[ -z "$svc" ]] && continue
		count=$((count + 1))
		host_port="${url##*:}"
		printf "  Checking %-22s (port %-5s) ... " "$svc" "$host_port"
		if [ "$is_active" -ne 1 ]; then
			printf "%b[FAILED (Docker State: %s)]%b\n" "$RED" "$state" "$RESET"
			failed=$((failed + 1))
			continue
		fi
		if (timeout 1 bash -c "cat < /dev/null > /dev/tcp/127.0.0.1/$host_port" 2>/dev/null); then
			printf "%b[OK (Connected)]%b\n" "$GREEN" "$RESET"
		else
			printf "%b[FAILED (Connection Refused)]%b\n" "$RED" "$RESET"
			failed=$((failed + 1))
		fi
	done < <(just _query all)
	echo "─────────────────────────────────────────────────────────────────"
	if [ "$count" -eq 0 ]; then
		printf "%b❌ Uptime validation failed! No active port bindings found. Is the stack down?%b\n\n" "$RED" "$RESET"
		exit 1
	elif [ "$failed" -eq 0 ]; then
		printf "%b🎉 All checks passed successfully!%b\n\n" "$GREEN" "$RESET"
	else
		printf "%b❌ Uptime validation failed! (%s service(s) broken)%b\n\n" "$RED" "$failed" "$RESET"
		exit 1
	fi

# Query port bindings for automation scripts. Filters: all, web, tcp, udp
ports-query filter="all":
	just _query {{ filter }}

# ==============================================================================
# Build & Release
# ==============================================================================

# Production build (all apps) — runs inside Docker
app-build:
	just compose --profile build run --rm postiz-build

# Clean build volumes and artifacts (leaves dev infra intact)
app-build-purge:
	just compose --profile build down --remove-orphans --volumes --rmi local

# Build + push to origin
git-push branch="dev": app-build
	@echo "🚀 Pushing to origin/{{ branch }} + tags..."
	git push origin {{ branch }} --tags

# ==============================================================================
# Tag & Release
# ==============================================================================

# List all libre release tags (newest first)
git-tag:
	git tag --list 'v*-libre*' --sort=-v:refname

# Compute the next libre tag without creating it (read-only)
git-tag-next:
	#!/usr/bin/env bash
	set -euo pipefail
	if ! git remote get-url upstream > /dev/null 2>&1; then
		echo "❌ No 'upstream' remote configured" >&2; exit 1
	fi
	UPSTREAM_TAG=$(git ls-remote --tags upstream 2>/dev/null | grep -E 'refs/tags/v[0-9]+\.[0-9]+\.[0-9]+$' | sed 's/.*refs\/tags\///' | sort -V | tail -1)
	LATEST_LIBRE=$(git tag --list "${UPSTREAM_TAG}-libre*" --sort=-v:refname | head -1)
	if [ -z "$LATEST_LIBRE" ]; then
		echo "${UPSTREAM_TAG}-libre"
	else
		UP_ESC=$(echo "$UPSTREAM_TAG" | sed 's/\./\\./g')
		SUFFIX=$(echo "$LATEST_LIBRE" | sed "s/.*${UP_ESC}-libre//; s/^-//")
		echo "${UPSTREAM_TAG}-libre-$(( ${SUFFIX:-0} + 1 ))"
	fi

# Create annotated tag (must be on dev, tree clean, stack healthy)
git-tag-create:
	#!/usr/bin/env bash
	set -euo pipefail
	BRANCH=$(git branch --show-current)
	if [ "$BRANCH" != "dev" ]; then echo "❌ Must be on 'dev' branch" >&2; exit 1; fi
	if ! git diff-index --quiet HEAD --; then echo "❌ Working tree is dirty" >&2; exit 1; fi
	echo "🧪 Checking stack health..."
	if ! just app-backend-health > /dev/null 2>&1; then echo "❌ Backend unhealthy" >&2; exit 1; fi
	if ! just app-frontend-health > /dev/null 2>&1; then echo "❌ Frontend unhealthy" >&2; exit 1; fi
	TAG=$(just git-tag-next)
	if [ -z "${TAG:-}" ]; then echo "❌ Could not determine next tag" >&2; exit 1; fi
	if git rev-parse "refs/tags/$TAG" > /dev/null 2>&1; then echo "❌ Tag $TAG already exists" >&2; exit 1; fi
	echo "  Next tag: $TAG"
	read -p "Create tag? (y/N) " -n 1 -r
	echo; if [[ ! $REPLY =~ ^[Yy]$ ]]; then echo "Aborted."; exit 0; fi
	git tag -a "$TAG" -m "Release $TAG"
	echo "✅ $TAG created"

# Check for stack resource leftovers (exit 0=clean, exit 1=residues)
is-purged:
	#!/usr/bin/env bash
	set -euo pipefail
	PROJECT=$(just _project-name)
	CONTAINERS=$(docker ps -aq --filter "label=com.docker.compose.project=${PROJECT}" | wc -l)
	VOLUMES=$(docker volume ls -q --filter "label=com.docker.compose.project=${PROJECT}" | wc -l)
	NETWORKS=$(docker network ls -q --filter "label=com.docker.compose.project=${PROJECT}" | wc -l)
	IMAGES=$(docker images -q --filter "label=com.docker.compose.project=${PROJECT}" | wc -l)
	MY_IMAGES=$(docker images -q --filter "reference=ghcr.io/oopen/postiz-libre*" | wc -l)
	ORPHAN_CT=$(docker ps -aq --filter "name=postiz" 2>/dev/null | wc -l)
	CACHE=$(docker builder du --human-readable 2>/dev/null | tail -1 | awk '{print $1}') || true
	echo "🗑️  Audit: ${PROJECT}"
	echo "  Containers      : ${CONTAINERS}"
	echo "  Volumes         : ${VOLUMES}"
	echo "  Networks        : ${NETWORKS}"
	echo "  Images (built)  : ${IMAGES}"
	echo "  Images (pull)   : ${MY_IMAGES}"
	echo "  Orphans (name)  : ${ORPHAN_CT}"
	echo "  Build cache     : ${CACHE:-N/A}"
	echo "  ──────────────────────────"
	TOTAL=$((CONTAINERS + VOLUMES + NETWORKS + IMAGES + MY_IMAGES + ORPHAN_CT))
	if [ "$TOTAL" -eq 0 ]; then echo "✅ Clean"; else echo "⚠️  ${TOTAL} leftover(s) — run just purge"; fi

# ==============================================================================
# Private Helpers (Hidden from 'just --list')
# ==============================================================================

# Get active compose project name
_project-name:
	@just compose config 2>/dev/null | sed -n 's/^name: *//p'

_query filter:
	#!/usr/bin/env bash
	set -euo pipefail
	just compose ps --format json | awk -v mode="{{ filter }}" -v web_services_str="{{ WEB_SERVICES }}" '
	BEGIN {
		split(web_services_str, ws_arr, " ")
		for (i in ws_arr) {
			split(ws_arr[i], p_arr, ":")
			s_name = p_arr[1]
			s_port = p_arr[2] + 0
			web_lookup[s_name ":" s_port] = 1
		}
	}
	{
		if (match($0, /"Service":"[^"]+"/)) {
			svc_block = substr($0, RSTART, RLENGTH)
			split(svc_block, svc_part, ":\"")
			svc = substr(svc_part[2], 1, length(svc_part[2])-1)
		} else { next }
		if (match($0, /"State":"[^"]+"/)) {
			state_block = substr($0, RSTART, RLENGTH)
			split(state_block, state_part, ":\"")
			state = substr(state_part[2], 1, length(state_part[2])-1)
		}
		is_active = (state ~ /exited/ || state ~ /dead/ || state ~ /paused/) ? 0 : 1
		str = $0
		while (match(str, /\{"URL":"[^"]+","[^}]+/)) {
			port_block = substr(str, RSTART, RLENGTH)
			str = substr(str, RSTART + RLENGTH)
			host_port = 0
			internal_port = 0
			layer_proto = "tcp"
			if (match(port_block, /"PublishedPort":[0-9]+/)) {
				pub_block = substr(port_block, RSTART, RLENGTH)
				match(pub_block, /[0-9]+/)
				host_port = substr(pub_block, RSTART, RLENGTH) + 0
			}
			if (match(port_block, /"TargetPort":[0-9]+/)) {
				tgt_block = substr(port_block, RSTART, RLENGTH)
				match(tgt_block, /[0-9]+/)
				internal_port = substr(tgt_block, RSTART, RLENGTH) + 0
			}
			if (match(port_block, /"Protocol":"[^"]+"/)) {
				split(substr(port_block, RSTART, RLENGTH), proto_part, ":\"")
				layer_proto = substr(proto_part[2], 1, length(proto_part[2])-1)
			}
			if (host_port == 0) continue
			dup_key = svc ":" host_port ":" layer_proto
			if (seen[dup_key]++) continue
			app_proto = "tcp"
			lookup_key = svc ":" internal_port
			if (internal_port == 443 || host_port == 443) {
				app_proto = "https"
			} else if (lookup_key in web_lookup) {
				app_proto = "http"
			}
			if (mode == "tcp" && layer_proto != "tcp") continue
			if (mode == "udp" && layer_proto != "udp") continue
			if (mode == "web" && (app_proto != "http" && app_proto != "https")) continue
			url = (app_proto == "tcp") ? "localhost:" host_port : app_proto "://localhost:" host_port
			printf "%s|%s|%s|%s|%s|%s\n", is_active, state, svc, url, internal_port, layer_proto
		}
	}
	'
