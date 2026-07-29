#!/usr/bin/env bash
set -euo pipefail
echo "🛑 Stopping dev servers..."

pkill -f "dev-backend" 2>/dev/null || true
pkill -f "nest start" 2>/dev/null || true
pkill -f "next dev" 2>/dev/null || true
sleep 2

pkill -9 -f "dev-backend" 2>/dev/null || true
pkill -9 -f "nest start" 2>/dev/null || true
pkill -9 -f "next dev" 2>/dev/null || true
sleep 1

source .env 2>/dev/null || true
fuser -k ${PORT:-3000}/tcp 2>/dev/null || true
fuser -k ${FRONTEND_PORT:-4200}/tcp 2>/dev/null || true

echo "✅ Stopped"