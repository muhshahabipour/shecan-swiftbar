#!/bin/zsh

ACTION="$1"

case "$ACTION" in
  start|stop|status)
    exec /bin/zsh -ic "if command -v shadcn >/dev/null 2>&1; then shadcn $ACTION; else /usr/local/bin/shecan $ACTION; fi"
    ;;
  *)
    echo "Usage: shecan-action.sh {start|stop|status}"
    exit 2
    ;;
esac
