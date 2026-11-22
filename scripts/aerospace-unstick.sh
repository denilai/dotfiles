#!/usr/bin/env bash
# Лечит «залипшее» окно: AeroSpace считает его macos_native_fullscreen, хотя приложение
# уже не в fullscreen, и команды раскладки отвечают «Can't change layout…».
#
#   scripts/aerospace-unstick.sh [window-id]   # без аргумента — окно в фокусе
#
# Окно переносится на другой воркспейс и обратно, после этого AeroSpace определяет его
# заново как обычное. Фокус возвращается на окно. Запускается из сервисного режима
# AeroSpace (Hyper+;, затем X).
set -euo pipefail

# AeroSpace запускает скрипт с урезанным PATH
AS="$(command -v aerospace || true)"
[ -x /opt/homebrew/bin/aerospace ] && AS=/opt/homebrew/bin/aerospace
[ -n "$AS" ] || { echo "aerospace не найден" >&2; exit 1; }

id="${1:-$("$AS" list-windows --focused --format '%{window-id}')}"
ws="$("$AS" list-windows --all --format '%{window-id} %{workspace}' | awk -v id="$id" '$1==id {print $2}')"
[ -n "$ws" ] || { echo "окно $id не найдено" >&2; exit 1; }

# временный воркспейс: любой из разовых, кроме текущего
tmp=3
[ "$ws" = 3 ] && tmp=2

"$AS" move-node-to-workspace --window-id "$id" "$tmp"
sleep 0.2
"$AS" move-node-to-workspace --window-id "$id" "$ws"
"$AS" workspace "$ws"
"$AS" focus --window-id "$id"
echo "окно $id ($ws): $("$AS" list-windows --all --format '%{window-id} %{window-layout}' | awk -v id="$id" '$1==id {print $2}')"
