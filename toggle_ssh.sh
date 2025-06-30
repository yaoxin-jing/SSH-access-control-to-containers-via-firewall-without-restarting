#!/bin/bash
# toggle_ssh.sh — enables or disables SSH access on port 2222 via nftables raw prerouting

set -e

PORT=2222
TABLE="ip"
CHAIN="prerouting"

usage() {
  echo "Usage: $0 [enable|disable|status]"
  exit 1
}

ensure_table_and_chain() {
  sudo nft add table $TABLE raw 2>/dev/null || true
  sudo nft add chain $TABLE raw $CHAIN '{ type filter hook prerouting priority -300; policy accept; }' 2>/dev/null || true
}

disable_ssh() {
  ensure_table_and_chain
  echo "[+] Adding DROP rule for TCP dport $PORT..."
  sudo nft add rule $TABLE raw $CHAIN tcp dport $PORT drop
  echo "[✓] SSH on port $PORT has been disabled."
}

enable_ssh() {
  ensure_table_and_chain
  echo "[+] Looking for DROP rule on TCP dport $PORT in $TABLE $CHAIN..."
  
  RULE_HANDLE=$(sudo nft -a list chain $TABLE $CHAIN | grep "tcp dport $PORT drop" | awk '{print $NF}')

  if [ -z "$RULE_HANDLE" ]; then
    echo "[✓] No DROP rule found — SSH is already enabled."
    return 0
  fi

  echo "[+] Deleting rule with handle $RULE_HANDLE..."
  sudo nft delete rule $TABLE $CHAIN handle "$RULE_HANDLE"
  echo "[✓] SSH on port $PORT has been re-enabled."
}

check_status() {
  sudo nft -a list chain $TABLE raw $CHAIN | grep "tcp dport $PORT drop" >/dev/null
  if [ $? -eq 0 ]; then
    echo "[🔒] SSH is currently DISABLED on port $PORT."
  else
    echo "[🟢] SSH is currently ENABLED on port $PORT."
  fi
}

case "$1" in
  enable)
    enable_ssh
    ;;
  disable)
    disable_ssh
    ;;
  status)
    check_status
    ;;
  *)
    usage
    ;;
esac