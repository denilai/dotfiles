#!/usr/bin/env bash
# Показать или спрятать шпаргалку AeroSpace (docs/aerospace-cheatsheet.html).
#
#   scripts/aerospace-cheatsheet.sh [toggle]   # открыть, а если открыта — закрыть
#   scripts/aerospace-cheatsheet.sh open|close
#
# Запускается из AeroSpace по клавише F20 (.aerospace.toml): клавиатура Corne шлёт её
# комбо двух крайних sticky Shift третьего ряда.
#
# Окно показывает KeymapView.app из репозитория corne-keyboard-layout
# (~/Applications/KeymapView.app, собирается его scripts/keymap-view.sh build): его
# запуск через `open` даёт окно поверх других и с фокусом, Esc или Cmd+W закрывают.
# Заголовок окна у него «Corne keymap». Если приложения нет, шпаргалка открывается
# в браузере по умолчанию. Открытое окно KeymapView закрывается тем же вызовом.
#
# Окно плавающее и остаётся на текущем воркспейсе AeroSpace: правило в .aerospace.toml
# делает его плавающим, а скрипт кладёт на воркспейс, откуда его вызвали, и возвращает
# туда фокус (иначе из пустого воркспейса AeroSpace перескакивает на воркспейс
# последнего активного окна). При закрытии фокус тоже возвращается на текущий воркспейс.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HTML="$REPO/docs/aerospace-cheatsheet.html"
APP="$HOME/Applications/KeymapView.app"
BUNDLE="local.corne.keymapview"
action="${1:-toggle}"

# AeroSpace запускает скрипт с урезанным PATH
AS="$(command -v aerospace || true)"
[ -x /opt/homebrew/bin/aerospace ] && AS=/opt/homebrew/bin/aerospace
focused_ws() { [ -n "$AS" ] && "$AS" list-workspaces --focused 2>/dev/null || true; }

is_open() { pgrep -x KeymapView >/dev/null; }

open_it() {
    local ws id="" i
    ws="$(focused_ws)"
    if [ -d "$APP" ]; then open -n "$APP" --args "$HTML"; else open "$HTML"; return 0; fi
    [ -n "$ws" ] || return 0
    for i in $(seq 1 30); do
        id="$("$AS" list-windows --monitor all --app-bundle-id "$BUNDLE" --format '%{window-id}' 2>/dev/null | head -1)"
        [ -n "$id" ] && break
        sleep 0.1
    done
    [ -n "$id" ] || return 0
    "$AS" move-node-to-workspace --window-id "$id" "$ws" >/dev/null 2>&1 || true
    "$AS" workspace "$ws" >/dev/null 2>&1 || true
    "$AS" focus --window-id "$id" >/dev/null 2>&1 || true
}

close_it() {
    local ws
    ws="$(focused_ws)"
    pkill -x KeymapView || true
    if [ -n "$ws" ]; then sleep 0.2; "$AS" workspace "$ws" >/dev/null 2>&1 || true; fi
}

case "$action" in
toggle) if is_open; then close_it; else open_it; fi ;;
open) is_open || open_it ;;
close) close_it ;;
*) sed -n '2,18p' "$0"; exit 2 ;;
esac
