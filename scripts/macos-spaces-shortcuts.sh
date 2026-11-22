#!/usr/bin/env bash
# Включает или выключает четыре системных сочетания macOS, которые перехватывают
# ⌃←/→/↑/↓ раньше AeroSpace: Move left / right a space, Mission Control, Application windows.
# Клавиши Nav+; Nav+' Nav+F Nav+G на Corne шлют именно их, а AeroSpace их слушает
# (.aerospace.toml: ctrl-left/right/up/down).
#
#   scripts/macos-spaces-shortcuts.sh off   # отключить четыре сочетания (для AeroSpace)
#   scripts/macos-spaces-shortcuts.sh on    # вернуть их
#
# Перед правкой настройки com.apple.symbolichotkeys сохраняются в
# ${XDG_STATE_HOME:-~/.local/state}/dotfiles/symbolichotkeys-<дата>.plist. Изменения подхватываются
# сразу, перелогин не нужен. Руками то же самое: System Settings → Keyboard → Keyboard
# Shortcuts → Mission Control. Другие сочетания не затрагиваются.
set -euo pipefail

mode="${1:-}"
case "$mode" in
    on|off) ;;
    *) sed -n '2,13p' "$0"; exit 2 ;;
esac

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
defaults export com.apple.symbolichotkeys "$tmp"

state="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
mkdir -p "$state"
backup="$state/symbolichotkeys-$(date +%Y%m%d-%H%M%S).plist"
cp "$tmp" "$backup"
echo "резервная копия: $backup"

python3 -I - "$tmp" "$mode" <<'PY'
import plistlib
import sys

path, mode = sys.argv[1:]
with open(path, "rb") as f:
    data = plistlib.load(f)
hot = data.setdefault("AppleSymbolicHotKeys", {})
# id сочетания -> код стрелки (⌃ + стрелка): 32 Mission Control ↑, 33 Application windows ↓,
# 79 Move left a space ←, 81 Move right a space →
KEYS = {"32": 126, "33": 125, "79": 123, "81": 124}
for key, arrow in KEYS.items():
    entry = hot.get(key, {})
    entry["enabled"] = mode == "on"
    entry.setdefault("value", {"parameters": [65535, arrow, 8650752], "type": "standard"})
    hot[key] = entry
with open(path, "wb") as f:
    plistlib.dump(data, f)
PY

defaults import com.apple.symbolichotkeys "$tmp"
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
echo "сочетания ⌃←/→/↑/↓ (Spaces, Mission Control, Application windows): $mode"
