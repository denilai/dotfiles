#!/usr/bin/env bash
# Подключает файл или каталог из репозитория в домашнюю директорию симлинком.
# Путь в репозитории равен пути относительно $HOME: .aerospace.toml → ~/.aerospace.toml.
#
#   scripts/link.sh .aerospace.toml          # создать ~/.aerospace.toml → <репозиторий>/.aerospace.toml
#   scripts/link.sh --diff .aerospace.toml   # показать, что будет, ничего не менять
#
# Подключается только то, что названо в аргументах. Существующий файл или каталог
# в $HOME сохраняется как <путь>.bak-<дата>.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dry=0
[ "${1:-}" = "--diff" ] && { dry=1; shift; }
[ $# -ge 1 ] || { echo "usage: $0 [--diff] <path relative to repo>..." >&2; exit 2; }

for rel in "$@"; do
    rel="${rel%/}"
    src="$REPO/$rel"
    dst="$HOME/$rel"
    [ -e "$src" ] || { echo "нет $src" >&2; exit 1; }

    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        echo "уже подключено: $dst -> $src"
        continue
    fi
    if [ $dry = 1 ]; then
        if [ -e "$dst" ] || [ -L "$dst" ]; then
            echo "будет сохранён как $dst.bak-<дата> и заменён симлинком на $src"
            [ -f "$dst" ] && [ -f "$src" ] && { diff -u "$dst" "$src" || true; }
        else
            echo "будет создан симлинк $dst -> $src"
        fi
        continue
    fi
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        backup="$dst.bak-$(date +%Y%m%d-%H%M%S)"
        mv "$dst" "$backup"
        echo "копия: $backup"
    fi
    ln -s "$src" "$dst"
    echo "подключено: $dst -> $src"
done
