# ==============================================================================
# Project Customization (Modify this for each new project)
# ==============================================================================

# Define precise web services that require http:// or https:// routing.
# Format: "service_name:internal_port" (space-separated)
WEB_SERVICES := "temporal-ui:8080 postiz-pg-admin:80 postiz-redisinsight:5540"

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
	@just --list
	@echo ""
	@echo "💡 Quick Start:"
	@echo "  just up                       # Start Docker infra + app servers"
	@echo "  just stop                     # Stop app servers + freeze containers"
	@echo "  just restart                  # Reboot everything"
	@echo "  just push                     # Build + push to origin"
	@echo ""
	@echo "💡 Environment Usage Examples:"
	@echo "  just up                       # Start in dev mode (default)"
	@echo "  ENV=prod just up              # Start in production mode"
	@echo "  ENV=test just test-health     # Test health in testing mode"
	@echo ""
	@echo "📋 Allowed ENV values: dev, prod, test"
	@echo ""
	@echo "🛑 Shutdown Lifecycle Guide (Know the difference!):"
	@echo "  just stop                     # PAUSE: Stop apps, freeze containers. Keeps ALL data/cache. (Fast)"
	@echo "  just restart                  # REBOOT: Fast stop and safe start. Keeps ALL data/cache."
	@echo "  just reset                    # RESET DATA: Destroys containers, networks & database VOLUMES."
	@echo "  just purge                    # TOTAL PURGE: Destroys everything + purges local built image cache."
	@echo ""
	@echo "📦 App Server Commands:"
	@echo "  just app-start                # Start Node.js servers (backend + frontend)"
	@echo "  just app-stop                 # Stop Node.js servers"
	@echo "  just app-clean                # Stop servers + remove build artifacts"
	@echo "  just build                    # Clean + production build all apps"
	@echo "  just push [branch]            # Build + push branch to origin (default: dev)"
	@echo ""
	@echo "⚙️ Current Context:"
	@echo "  Active Environment : {{ RAW_ENV }} (normalized: {{ ENV }})"
	@echo "  Target Config File : {{ COMPOSE_FILE }}"
	@echo ""

# Wrapper to execute any native docker compose command within the detected environment
compose *args:
	@docker compose {{ args }}

# Start all services detached using cache, show ports, run healthchecks, then start app servers
up:
	docker compose up -d --remove-orphans
	@just ports
	@just test-health
	@just app-start

# Force download, rebuild, and recreate the entire stack with clean anonymous volumes
rebuild:
	docker compose up -d --remove-orphans --pull always --build --force-recreate --renew-anon-volumes
	@just ports
	@just test-health

# Stop app servers and containers without removing them (freezes state, preserves memory/disk)
stop:
	@just app-stop
	@docker compose stop

# Fast and safe reboot of the stack without data loss
restart: stop up

# Stop and remove all containers, networks, and database volumes (wipes databases)
reset:
	docker compose down --remove-orphans --volumes

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
	docker compose down --remove-orphans --volumes --rmi local
	
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
		docker compose up -d --remove-orphans
		@just ports
		@just test-health
	else
		echo "🚀 Ensuring service '{{ target }}' is up..."
		docker compose up -d --remove-orphans "{{ target }}"
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

# Run automated healthchecks on all published services to verify uptime and port connectivity
test-health:
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
	@just _query {{ filter }}

# ==============================================================================
# App Server & Push
# ==============================================================================

# Stop the Node.js app servers (backend + frontend)
app-stop:
	@bash scripts/app-stop.sh

# Clean: stop app servers + remove all build artifacts
app-clean: app-stop
	#!/usr/bin/env bash
	set -euo pipefail
	echo "🧹 Cleaning build artifacts..."
	rm -rf apps/backend/dist apps/frontend/dist apps/frontend/.next apps/orchestrator/dist

# Start app servers (backend + frontend)
app-start:
	#!/usr/bin/env bash
	set -euo pipefail
	source .env 2>/dev/null || true
	export FRONTEND_PORT
	export PORT
	echo "🚀 Starting app servers on ports ${PORT:-3000}/${FRONTEND_PORT:-4200}..."
	pnpm run dev-backend

# Production build (all apps)
build: app-clean
	@echo "🔨 Building..."
	pnpm run build

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
	
	docker compose ps --format json | awk -v mode="{{ filter }}" -v web_services_str="{{ WEB_SERVICES }}" '
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
