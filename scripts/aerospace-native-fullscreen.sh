#!/usr/bin/env bash
# Безопасное переключение нативного fullscreen macOS для окна в фокусе.
#
#   scripts/aerospace-native-fullscreen.sh [window-id]
#
# Обычный toggle (`macos-native-fullscreen`) на «залипшем» окне (AeroSpace считает его
# macos_native_fullscreen, хотя приложение уже не в fullscreen) включает fullscreen ещё раз,
# и окно уезжает на скрытые координаты. Поэтому направление выбирается по состоянию окна:
#   - окно в macos_native_fullscreen → `off`; если после этого оно всё ещё числится в
#     fullscreen, оно залипло, и его расклеивает scripts/aerospace-unstick.sh;
#   - иначе → `on`.
# AeroSpace после выхода из fullscreen ставит окно в тайлы, даже если оно было плавающим:
# раскладка запоминается перед `on` (в ${XDG_STATE_HOME:-~/.local/state}/aerospace/) и
# возвращается после `off`.
# Запускается из сервисного режима AeroSpace (Hyper+;, затем N).
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# AeroSpace запускает скрипт с урезанным PATH
AS="$(command -v aerospace || true)"
[ -x /opt/homebrew/bin/aerospace ] && AS=/opt/homebrew/bin/aerospace
[ -n "$AS" ] || { echo "aerospace не найден" >&2; exit 1; }

id="${1:-$("$AS" list-windows --focused --format '%{window-id}')}"
state="${XDG_STATE_HOME:-$HOME/.local/state}/aerospace"
saved="$state/native-fullscreen-$id"
restore() {
    if [ "$(cat "$saved" 2>/dev/null)" = floating ]; then
        "$AS" layout --window-id "$id" floating || true
    fi
    rm -f "$saved"
}
layout() { "$AS" list-windows --monitor all --format '%{window-id} %{window-layout}' | awk -v id="$id" '$1==id {print $2}'; }

if [ "$(layout)" = macos_native_fullscreen ]; then
    "$AS" macos-native-fullscreen --window-id "$id" off || true
    # выход из fullscreen — анимация macOS, ждём до 3 с
    for _ in $(seq 1 15); do
        [ "$(layout)" = macos_native_fullscreen ] || { restore; echo "окно $id: fullscreen выключен"; exit 0; }
        sleep 0.2
    done
    echo "окно $id залипло, расклеиваю"
    "$DIR/aerospace-unstick.sh" "$id"
    restore
else
    mkdir -p "$state"
    case "$(layout)" in floating) echo floating ;; *) echo tiling ;; esac > "$saved"
    "$AS" macos-native-fullscreen --window-id "$id" on
    echo "окно $id: fullscreen включён"
fi
