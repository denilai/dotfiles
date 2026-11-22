# AeroSpace

[AeroSpace](https://github.com/nikitabobko/AeroSpace) — тайлинговый менеджер окон
для macOS. Окна сами делят экран, воркспейсы свои (не macOS Spaces), управление с
клавиатуры.

## Где что

| Что | Где |
|---|---|
| Конфиг | `.aerospace.toml` в этом репозитории |
| Живой файл | `~/.aerospace.toml` — симлинк на конфиг из репозитория (`scripts/link.sh .aerospace.toml`) |
| Установка программы | `brew install --cask nikitabobko/tap/aerospace` |
| Правила и подводные камни | скил `aerospace` (`~/.claude/skills/aerospace/SKILL.md`) |
| Раскладка клавиатуры, от которой строятся привязки | `~/repos/personal/corne-keyboard-layout` (Corne, `config/corne.keymap`) |

Конфиг правится только в репозитории. После правки: `aerospace reload-config`
(или `auto-reload-config = true`, пока выключено).

## Состояние конфига

Сейчас это стандартный пример из документации AeroSpace без правок:

- модификатор — `alt` (Option): `alt-h/j/k/l` фокус, `alt-shift-h/j/k/l` переместить
  окно, `alt-1…9` и `alt-a…z` воркспейсы, `alt-shift-<клавиша>` отправить окно на
  воркспейс, `alt-tab` вернуться на прошлый воркспейс, `alt-slash` / `alt-comma`
  раскладки `tiles` / `accordion`, `alt-minus` / `alt-equal` размер;
- сервисный режим `alt-shift-;`: `f` плавающее окно, `r` сбросить раскладку
  воркспейса, `alt-shift-h/j/k/l` объединить окно с соседом, `backspace` закрыть
  остальные окна, `esc` перечитать конфиг;
- 31 постоянный воркспейс (`1–9`, `A–Z` без `H J K L`), зазоров нет;
- `start-at-login = false`, `auto-reload-config = false`.

## Что нужно знать

- Окна видны AeroSpace только с разрешением Accessibility (System Settings →
  Privacy & Security). Если `aerospace list-windows --all` пуст, а
  `aerospace list-apps` нет, разрешение «протухло»: выключить и включить
  переключатель, перезапустить AeroSpace.
- Проверка, что конфиг загрузился: `aerospace list-modes` (должны быть `main` и
  `service`).
- Не использовать зелёную кнопку окна (macOS-fullscreen): она создаёт отдельный
  Space. Вместо неё `aerospace fullscreen`.
- Если AeroSpace завершили жёстко, окна неактивных воркспейсов остаются за краем
  экрана: запустить AeroSpace снова. Временно отключить тайлинг:
  `aerospace enable off`.
- Привязки на `alt` перехватывают Option+буква. На клавиатуре Corne Alt лежит на
  home row (S и L при удержании), поэтому планируется модификатор Hyper
  (удержание правого Del thumb, ⌃⌥⇧⌘).

Планы по этому конфигу — в [TODO.md](../TODO.md).
