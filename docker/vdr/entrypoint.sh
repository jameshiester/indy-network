#!/bin/bash
set -euo pipefail

: "${VDR_PROXY_PORT:=8080}"
: "${VDR_GENESIS_PATH:=}"

BIN="/opt/indy-vdr/target/release/indy-vdr-proxy"
if [[ ! -x "$BIN" ]]; then
  BIN="/opt/indy-vdr/target/debug/indy-vdr-proxy"
fi
if [[ ! -x "$BIN" ]]; then
  echo "indy-vdr-proxy not found at $BIN (checked release and debug)" >&2
  exit 1
fi

cmd=("$BIN" "-p" "${VDR_PROXY_PORT}")

if [[ -n "${VDR_GENESIS_PATH}" ]]; then
  cmd+=("-g" "${VDR_GENESIS_PATH}")
fi

exec "${cmd[@]}"


