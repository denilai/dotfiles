# AeroSpace

[AeroSpace](https://github.com/nikitabobko/AeroSpace) — тайлинговый менеджер окон
для macOS. Окна сами делят экран, воркспейсы свои (не macOS Spaces), управление с
клавиатуры.

## Где что

| Что | Где |
|---|---|
| Конфиг | `.aerospace.toml` в этом репозитории |
| Живой файл | `~/.aerospace.toml` — симлинк на конфиг из репозитория (`scripts/link.sh .aerospace.toml`) |
| Шпаргалка | [aerospace-cheatsheet.html](aerospace-cheatsheet.html), открывается скриптом `scripts/aerospace-cheatsheet.sh` |
| Установка программы | `brew install --cask nikitabobko/tap/aerospace` |
| Правила и подводные камни | скил `aerospace` (`~/.claude/skills/aerospace/SKILL.md`) |
| Раскладка клавиатуры, от которой строятся привязки | `~/repos/personal/corne-keyboard-layout` (Corne, `config/corne.keymap`) |

Конфиг правится только в репозитории. Перечитывается сам (`auto-reload-config`),
вручную `aerospace reload-config`.

## Состояние конфига

- **Воркспейсы по ролям:** `T` терминал и редактор (Terminal, VS Code, Docker Desktop,
  Notes, TextEdit), `B` Chrome, `P` Vivaldi, `D` Obsidian и чат-приложение, `F` системные
  окна (Finder, System Settings, Activity Monitor; плавающие), `S` Slack, Calendar, Gmail,
  Google Calendar, Google Meet (три последних — приложения Chrome со своими id); `1 2 3` для
  разового. Приложения попадают на свой воркспейс правилами `[[on-window-detected]]`
  в момент появления окна.
- **Модификатор — Hyper** (`ctrl-alt-shift-cmd`, удержание правого Del thumb или левого
  Enter thumb на Corne: буквы любой половины нажимаются с Hyper противоположной руки):
  `H J K L` фокус, буква роли (`T B P D F S 1 2 3`) — воркспейс, `Tab` — прошлый
  воркспейс, `/` `,` `.` — тайлы, аккордеон, плавающее, `Enter` — на весь воркспейс,
  `=` — выровнять размеры.
- **Режимы:** `Hyper+M` — перенос окна (`H J K L` двигают, буква или цифра отправляет на
  воркспейс), `Hyper+R` — размер, `Alt+Shift+;` — сервисный (сброс раскладки, float, объединение).
- **Запасные `alt`-биндинги** (фокус, перенос, воркспейсы ролей, раскладки, размер) оставлены,
  пока Hyper не проверен на железе.
- **Шпаргалка по F20:** привязка `f20` запускает `scripts/aerospace-cheatsheet.sh toggle`;
  F20 шлёт комбо двух крайних sticky Shift третьего ряда Corne.
- Зазоры 8 px, `start-at-login = true`, `auto-reload-config = true`.

## Шпаргалка

`docs/aerospace-cheatsheet.html` — белая страница с воркспейсами, сочетаниями и тем, что
нельзя забыть. Окно показывает `KeymapView.app` из репозитория Corne
(`~/Applications/KeymapView.app`, собирается его `scripts/keymap-view.sh build`): окно поверх
остальных и с фокусом, Esc или Cmd+W закрывают, повторное комбо тоже. Заголовок окна у него
«Corne keymap». Окно плавающее и остаётся на текущем воркспейсе: правило `[[on-window-detected]]`
делает его плавающим, а скрипт кладёт на воркспейс, откуда его вызвали, и возвращает туда фокус
(иначе из пустого воркспейса AeroSpace перескакивал на воркспейс последнего активного окна);
при закрытии перескока тоже нет. Так же ведёт себя шпаргалка по Corne (`scripts/keymap-view.sh`
в репозитории Corne). Без этого приложения шпаргалка откроется в браузере по умолчанию. **При
изменении конфига, ролей или сочетаний обновлять шпаргалку.**

## Что нужно знать

- Окна видны AeroSpace только с разрешением Accessibility (System Settings →
  Privacy & Security). Если `aerospace list-windows --all` пуст, а
  `aerospace list-apps` нет, разрешение «протухло»: выключить и включить
  переключатель, перезапустить AeroSpace.
- Проверка, что конфиг загрузился: `aerospace list-modes` (`main`, `move`, `resize`,
  `service`). Привязку можно проверить без клавиатуры: `aerospace trigger-binding --mode main
  ctrl-alt-shift-cmd-t`.
- Правила приложений срабатывают один раз при появлении окна: открытые заранее остаются где были.
- Не использовать зелёную кнопку окна (macOS-fullscreen): она создаёт отдельный
  Space. Вместо неё `Hyper+Enter` (`aerospace fullscreen`).
- Если AeroSpace завершили жёстко, окна неактивных воркспейсов остаются за краем
  экрана: запустить AeroSpace снова. Временно отключить тайлинг:
  `aerospace enable off`.
- Привязки на `alt` перехватывают Option+буква, поэтому основной модификатор — Hyper.

Планы по этому конфигу — в [TODO.md](../TODO.md).
