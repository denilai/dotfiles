#!/usr/bin/env bash
# Включает или выключает встроенный тайлинг окон macOS (Sequoia и новее) и растягивание окна
# двойным кликом по заголовку: оба мешают AeroSpace, macOS растягивает окно сама, AeroSpace об
# этом не знает.
#
#   scripts/macos-window-tiling.sh off   # выключить (для AeroSpace)
#   scripts/macos-window-tiling.sh on    # вернуть
#   scripts/macos-window-tiling.sh       # показать текущее состояние
#
# Затрагивает три настройки System Settings → Desktop & Dock → Windows:
# «Drag windows to screen edges to tile», «Drag windows to menu bar to fill screen»,
# «Hold ⌥ key while dragging windows to tile», а также «Double-click a window's title bar to»
# (AppleActionOnDoubleClick: off — None, on — значение по умолчанию, Zoom/Fill). Перед правкой
# настройки сохраняются в ${XDG_STATE_HOME:-~/.local/state}/dotfiles/windowmanager-<дата>.plist
# и doubleclick-<дата>.txt.
set -euo pipefail

KEYS=(EnableTilingByEdgeDrag EnableTopTilingByEdgeDrag EnableTilingOptionAccelerator)
DOMAIN=com.apple.WindowManager

show() {
    local k
    for k in "${KEYS[@]}"; do
        printf '%s = %s\n' "$k" "$(defaults read "$DOMAIN" "$k" 2>/dev/null || echo 'не задано (по умолчанию включено)')"
    done
    printf 'AppleActionOnDoubleClick = %s\n' "$(defaults read -g AppleActionOnDoubleClick 2>/dev/null || echo 'не задано (по умолчанию Zoom/Fill)')"
}

mode="${1:-}"
case "$mode" in
    on|off) ;;
    "") show; exit 0 ;;
    *) sed -n '2,15p' "$0"; exit 2 ;;
esac

state="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
mkdir -p "$state"
backup="$state/windowmanager-$(date +%Y%m%d-%H%M%S).plist"
defaults export "$DOMAIN" "$backup"
echo "резервная копия: $backup"

value=false
[ "$mode" = on ] && value=true
for k in "${KEYS[@]}"; do
    defaults write "$DOMAIN" "$k" -bool "$value"
done
defaults read -g AppleActionOnDoubleClick > "$state/doubleclick-$(date +%Y%m%d-%H%M%S).txt" 2>/dev/null || true
if [ "$mode" = off ]; then
    defaults write -g AppleActionOnDoubleClick -string None
else
    defaults delete -g AppleActionOnDoubleClick 2>/dev/null || true
fi
# WindowManager перечитывает настройки при перезапуске, macOS поднимает его сама
killall WindowManager 2>/dev/null || true
show
