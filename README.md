# Dotfiles

Переносимые конфигурационные файлы. Путь файла в репозитории равен пути
относительно `$HOME`: `.aerospace.toml` → `~/.aerospace.toml`,
`.config/alacritty/` → `~/.config/alacritty/`. Файл живёт только в репозитории,
в домашней директории лежит симлинк на него.

## Что есть

| Путь в репозитории | Что это | Платформа | Подключён на этом Mac |
|---|---|---|---|
| `.aerospace.toml` | конфиг тайлингового менеджера окон AeroSpace, см. [docs/aerospace.md](docs/aerospace.md) | macOS | да (симлинк) |
| `docs/aerospace-cheatsheet.html`, `scripts/aerospace-cheatsheet.sh` | шпаргалка по AeroSpace и скрипт, который её показывает (F20 → привязка в AeroSpace → скрипт; F20 шлёт комбо на Corne) | macOS | работает из репозитория, ссылок не нужно |
| `.githooks/pre-commit`, `scripts/check-aerospace-docs.py` | хук: проверка конфига AeroSpace (ошибки блокируют коммит) и сверка шпаргалки с конфигом (предупреждения) | любая | через `.git/hooks/pre-commit` (общий диспетчер), на новом клоне нужна ссылка, см. [CLAUDE.md](CLAUDE.md) |
| `.config/alacritty/alacritty.toml` | терминал Alacritty: шрифт 15, Ctrl+Shift+S — новое окно, Ctrl+правый клик — вставка, выделение копируется в буфер, тема `themes/aura.toml` | любая | нет |
| `.config/alacritty/catppuccin` | темы Catppuccin для Alacritty (записан как вложенный git-репозиторий без `.gitmodules`) | любая | нет |
| `.config/alacritty/themes` | симлинк на `/home/denilai/repos/thirdparty/alacritty-theme/themes/` (работает только на Linux-хосте с этим путём) | Linux | нет |
| `.config/xkb/symbols/us`, `ru` | свои XKB-раскладки (английская и русская «winkeys») | Linux | нет |
| `.config/proxyman/v2rayng` | профиль Proxyman: HTTP/HTTPS/FTP-прокси `127.0.0.1:10808` | Linux | нет |

## Подключение

Скрипт `scripts/link.sh` подключает только то, что назвали в аргументах, и ничего
больше. Существующий файл в `$HOME` сохраняется как `<путь>.bak-<дата>`.

```sh
scripts/link.sh --diff .aerospace.toml   # посмотреть, что изменится
scripts/link.sh .aerospace.toml          # создать симлинк ~/.aerospace.toml
```

Подключение XKB на Linux (вручную):

```sh
ln -s <путь к репозиторию>/.config/xkb/ ~/.config/xkb
```

## Правила репозитория

См. [CLAUDE.md](CLAUDE.md). План работ и известные замечания — в [TODO.md](TODO.md).
