# Define precise web services that require http:// or https:// routing.
# Format: "service_name:internal_port" (space-separated)
WEB_SERVICES := "temporal-ui:8080 postiz-pg-admin:80 postiz-redisinsight:5540 postiz-frontend:4200 postiz-backend:3000"

# ==============================================================================
# Configuration & Environment Detection
# ==============================================================================

RAW_ENV := env_var_or_default("ENV", "dev")
ENV     := lowercase(RAW_ENV)

export COMPOSE_FILE := \
  if ENV == "prod" { \
    "docker-compose.yaml" \
  } else if ENV == "test" { \
    "docker-compose.test.yaml" \
  } else { \
    "docker-compose.dev.yaml" \
  }

set positional-arguments := true

# ==============================================================================
# Recipes (Commands)
# ==============================================================================

# List available commands, environment status, and filtering usage
default:
	just --list
	@echo ""
	@echo "💡 Quick Start:"
	@echo "  just up                       # Start everything (Docker infra + app servers)"
	@echo "  just stop                     # Stop everything"
	@echo "  just restart                  # Reboot everything"
	@echo "  just push                     # Build + push to origin"
	@echo ""
	@echo "💡 Monitoring:"
	@echo "  just backend-health           # Check backend (DB, Redis, Temporal)"
	@echo "  just frontend-health          # Check frontend + backend status"
	@echo "  just app-logs                 # Tail app server logs"
	@echo "  just check-ports              # Check TCP port connectivity"
	@echo ""
	@echo "💡 Environment Usage Examples:"
	@echo "  just up                       # Start in dev mode (default)"
	@echo "  ENV=prod just up              # Start in production mode"
	@echo "  ENV=test just check-ports     # Test health in testing mode"
	@echo ""
	@echo "📋 Allowed ENV values: dev, prod, test"
	@echo ""
	@echo "🛑 Lifecycle Guide (Know the difference!):"
	@echo "  just stop                     # PAUSE: Freeze containers. Keeps ALL data/cache. (Fast)"
	@echo "  just restart                  # REBOOT: Fast stop and safe start. Keeps ALL data/cache."
	@echo "  just reset                    # RESET: Destroy containers + volumes, then fresh start."
	@echo "  just purge                    # TOTAL PURGE: Destroys everything + purges local built image cache."
	@echo ""
	@echo "📦 Build & Deploy:"
	@echo "  just build                    # Production build in Docker"
	@echo "  just build-purge              # Clean build volumes"
	@echo "  just push [branch]            # Build + push branch to origin (default: dev)"
	@echo ""
	@echo "⚙️ Current Context:"
	@echo "  Active Environment : {{ RAW_ENV }} (normalized: {{ ENV }})"
	@echo "  Target Config File : {{ COMPOSE_FILE }}"
	@echo ""

# Wrapper to execute any native docker compose command within the detected environment
compose *args:
	@docker compose {{ args }}

# Start all services: infra + backend, discover port, then frontend
up:
	#!/usr/bin/env bash
	set -euo pipefail
	# Stop stale frontend from previous runs
	just compose --profile frontend stop postiz-frontend 2>/dev/null || true
	# Phase 1: start infrastructure and backend
	just compose up -d --remove-orphans
	# Phase 2: wait for backend health (DB, Redis, Temporal)
	echo "⏳ Waiting for backend..."
	until just backend-health > /dev/null 2>&1; do sleep 2; done
	BACKEND_PORT=$(just compose port postiz-backend 3000 | cut -d: -f2)
	echo "NEXT_PUBLIC_BACKEND_URL=http://localhost:$BACKEND_PORT" > apps/frontend/.env.local
	echo "✅ Backend ready at localhost:$BACKEND_PORT"
	# Phase 3: start frontend
	just compose --profile frontend up -d --remove-orphans
	# Phase 4: wait for frontend health
	echo "⏳ Waiting for frontend..."
	until just frontend-health > /dev/null 2>&1; do sleep 2; done
	FRONTEND_PORT=$(just compose port postiz-frontend 4200 | cut -d: -f2)
	echo "✅ Frontend ready at localhost:$FRONTEND_PORT"
	# Status display
	just ports
	just check-ports

# Force download, rebuild, and recreate the entire stack with clean anonymous volumes
rebuild:
	just compose up -d --remove-orphans --pull always --build --force-recreate --renew-anon-volumes
	just ports
	just check-ports

# Stop containers without removing them (freezes state, preserves memory/disk)
stop:
	just compose stop

# Tail the app server logs
app-logs:
	just compose logs -f postiz-backend postiz-frontend

# Check backend application health (DB, Redis, Temporal)
backend-health:
	#!/usr/bin/env bash
	set -euo pipefail
	BACKEND_PORT=$(just compose port postiz-backend 3000 2>/dev/null | cut -d: -f2)
	if [ -z "${BACKEND_PORT:-}" ]; then echo "❌ Backend is not running"; exit 1; fi
	curl -s "http://localhost:$BACKEND_PORT/" || { echo "❌ Backend not responding"; exit 1; }

# Check frontend application health (includes backend status)
frontend-health:
	#!/usr/bin/env bash
	set -euo pipefail
	FRONTEND_PORT=$(just compose port postiz-frontend 4200 2>/dev/null | cut -d: -f2)
	if [ -z "${FRONTEND_PORT:-}" ]; then echo "❌ Frontend is not running"; exit 1; fi
	curl -s "http://localhost:$FRONTEND_PORT/api/health" || { echo "❌ Frontend not responding"; exit 1; }

# Fast and safe reboot of the stack without data loss
restart: stop up

# Stop and remove all containers, networks, and database volumes, then fresh start
reset:
	just compose --profile frontend --profile build down --remove-orphans --volumes
	just up

# Deep clean this local Docker stack (removes containers, volumes, and local built images)
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
	just compose --profile frontend --profile build down --remove-orphans --volumes --rmi local
	PROJECT=$(just compose config 2>/dev/null | sed -n 's/^name: *//p'); docker volume ls -q --filter name="${PROJECT}_" 2>/dev/null | while read -r vol; do docker volume rm -f "$vol" > /dev/null 2>&1 || true; done

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

# Open discovered web services in your browser. Automatically ensures the stack is running.
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
		just compose up -d --remove-orphans
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

# Query specific port bindings for automation scripts. Filters: all, web, tcp, udp
query filter="all":
	just _query {{ filter }}

# ==============================================================================
# Build & Push
# ==============================================================================

# Production build (all apps) — runs inside Docker
build:
	just compose --profile build run --rm postiz-build

# Clean build volumes and artifacts (leaves dev infra intact)
build-purge:
	just compose --profile build down --remove-orphans --volumes --rmi local

# Build + push to origin
push branch="dev": build
	@echo "🚀 Pushing to origin/{{ branch }}..."
	git push origin {{ branch }}

# ==============================================================================
# Private Helpers (Hidden from 'just --list')
# ==============================================================================

_query filter:
	#!/usr/bin/env bash
	set -euo pipefail
	
	just compose ps --format json | awk -v mode="{{ filter }}" -v web_services_str="{{ WEB_SERVICES }}" '
	BEGIN {
		# Parse custom web services list
		split(web_services_str, ws_arr, " ")
		for (i in ws_arr) {
			split(ws_arr[i], p_arr, ":")
			s_name = p_arr[1]
			s_port = p_arr[2] + 0
			web_lookup[s_name ":" s_port] = 1
		}
	}
	{
		# Safe extraction of Service name
		if (match($0, /"Service":"[^"]+"/)) {
			svc_block = substr($0, RSTART, RLENGTH)
			split(svc_block, svc_part, ":\"")
			svc = substr(svc_part[2], 1, length(svc_part[2])-1)
		} else { next }
		
		# Safe extraction of State
		state = "unknown"
		if (match($0, /"State":"[^"]+"/)) {
			state_block = substr($0, RSTART, RLENGTH)
			split(state_block, state_part, ":\"")
			state = substr(state_part[2], 1, length(state_part[2])-1)
		}
		
		is_active = (state ~ /exited/ || state ~ /dead/ || state ~ /paused/) ? 0 : 1
		
		# Unroll and isolate port mappings sequentially from the JSON text stream
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

