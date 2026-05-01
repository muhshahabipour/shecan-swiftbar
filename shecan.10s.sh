#!/bin/bash

INSTALL_DIR="__INSTALL_DIR__"
SHADCN_ACTION="$INSTALL_DIR/shecan-action.sh"
DNS1="178.22.122.101"
DNS2="185.51.200.1"

ICON_ON="$INSTALL_DIR/icons/on-small.png"
ICON_OFF="$INSTALL_DIR/icons/off-white.png"
CONNECTED_AT_FILE="$HOME/.shecan_connected_at"

format_uptime() {
  local start=$1
  local now elapsed h m s
  now=$(date +%s)
  elapsed=$(( now - start ))
  h=$(( elapsed / 3600 ))
  m=$(( (elapsed % 3600) / 60 ))
  s=$(( elapsed % 60 ))
  if (( h > 0 )); then
    echo "${h}h ${m}m"
  elif (( m > 0 )); then
    echo "${m}m ${s}s"
  else
    echo "${s}s"
  fi
}

icon_data() {
  /usr/bin/base64 < "$1" | /usr/bin/tr -d '\n'
}

get_active_service() {
  DEFAULT_IFACE=$(route -n get default 2>/dev/null | awk '/interface:/{print $2; exit}')

  if [ -n "$DEFAULT_IFACE" ]; then
    SERVICE=$(
      /usr/sbin/networksetup -listallhardwareports 2>/dev/null |
        awk -v iface="$DEFAULT_IFACE" '
          /^Hardware Port: / { port=substr($0, 16) }
          /^Device: / && substr($0, 9) == iface { print port; exit }
        '
    )
    if [ -n "$SERVICE" ]; then
      echo "$SERVICE"
      return
    fi
  fi

  for service in "Wi-Fi" "Ethernet" "USB 10/100/1000 LAN" "Thunderbolt Bridge"; do
    if /usr/sbin/networksetup -getinfo "$service" 2>/dev/null | grep -Eq '^IP address: ([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
      echo "$service"
      return
    fi
  done
}

SERVICE=$(get_active_service)
STATUS=""
if [ -n "$SERVICE" ]; then
  STATUS=$(/usr/sbin/networksetup -getdnsservers "$SERVICE" 2>/dev/null)
fi

is_on() {
  [[ "$STATUS" == *"$DNS1"* ]]
}

if is_on; then
  echo "| image=$(icon_data "$ICON_ON") tooltip=Shecan: connected on $SERVICE"
  echo "---"
  echo "✅ Connected: $SERVICE | color=green"
  echo "DNS: $DNS1, $DNS2"
  echo "---"
  echo "🔌 Stop Shecan | bash=$SHADCN_ACTION param1=stop terminal=false refresh=true"
  if [ -f "$CONNECTED_AT_FILE" ]; then
    START=$(cat "$CONNECTED_AT_FILE")
    echo "⏱ $(format_uptime "$START") | color=gray size=12"
  fi
else
  echo "| image=$(icon_data "$ICON_OFF") tooltip=Shecan: disconnected"
  echo "---"
  echo "❌ Disconnected | color=red"
  if [ -n "$SERVICE" ]; then echo "Service: $SERVICE"; fi
  echo "---"
  echo "🚀 Start Shecan | bash=$SHADCN_ACTION param1=start terminal=false refresh=true"
fi

echo "---"
echo "📊 Status | bash=$SHADCN_ACTION param1=status terminal=true"
