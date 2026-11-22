#!/usr/bin/env python3
"""Проверка .aerospace.toml и шпаргалки docs/aerospace-cheatsheet.html.

Вызывается из .githooks/pre-commit, можно вручную:
    python3 -I scripts/check-aerospace-docs.py [--config FILE] [--sheet FILE]

ОШИБКИ (код выхода 1, коммит блокируется): конфиг AeroSpace не загрузится.
  - невалидный TOML;
  - команда `split` при enable-normalization-flatten-containers = true: AeroSpace
    отказывается загружать такой конфиг (окно «Config Diagnostics»);
  - привязка включает режим, которого нет в конфиге;
  - привязка запускает скрипт, которого нет или он не исполняемый.

ПРЕДУПРЕЖДЕНИЯ (код выхода 0): шпаргалка отстала от конфига.
  - воркспейс из persistent-workspaces / правил или Hyper-клавиша не показаны в шпаргалке;
  - команда переносит окно на воркспейс, которого нет в persistent-workspaces;
  - конфиг в коммите изменён, а шпаргалка нет.

Шпаргалка написана вручную, поэтому хук её только сверяет, а не переписывает.
"""
import argparse
import os
import re
import subprocess
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
HYPER = "ctrl-alt-shift-cmd-"
# имя клавиши в конфиге -> как она написана в шпаргалке (<kbd>)
KEY_LABEL = {"tab": "Tab", "slash": "/", "comma": ",", "period": ".", "enter": "Enter",
             "equal": "=", "minus": "-", "semicolon": ";", "esc": "Esc", "space": "Space"}


def commands(value):
    return [value] if isinstance(value, str) else list(value)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", default=str(ROOT / ".aerospace.toml"))
    ap.add_argument("--sheet", default=str(ROOT / "docs" / "aerospace-cheatsheet.html"))
    ap.add_argument("--no-git", action="store_true", help="не сверять с индексом git")
    args = ap.parse_args()

    errors, warns = [], []

    try:
        cfg = tomllib.loads(Path(args.config).read_text())
    except (OSError, tomllib.TOMLDecodeError) as e:
        print(f"✘ {args.config}: {e}", file=sys.stderr)
        return 1

    modes = cfg.get("mode", {})
    flatten = cfg.get("enable-normalization-flatten-containers", False)
    persistent = [str(w) for w in cfg.get("persistent-workspaces", [])]

    all_cmds = []          # (где, команда)
    for mode, body in modes.items():
        for key, value in body.get("binding", {}).items():
            for c in commands(value):
                all_cmds.append((f"mode.{mode}.binding {key}", c))
    for rule in cfg.get("on-window-detected", []):
        for c in commands(rule.get("run", [])):
            all_cmds.append((f"on-window-detected {rule.get('if', {}).get('app-id', '?')}", c))

    for where, c in all_cmds:
        if flatten and re.match(r"\s*split\b", c):
            errors.append(f"{where}: команда `split` не работает при enable-normalization-flatten-containers = true, "
                          "AeroSpace не загрузит такой конфиг; используй `join-with`")
        m = re.match(r"\s*mode\s+(\S+)", c)
        if m and m.group(1) not in modes:
            errors.append(f"{where}: режим `{m.group(1)}` не описан в конфиге")
        m = re.match(r"\s*exec-and-forget\s+(\S+)", c)
        if m:
            script = Path(os.path.expandvars(m.group(1)))
            if not script.exists():
                errors.append(f"{where}: нет скрипта {script}")
            elif not os.access(script, os.X_OK):
                errors.append(f"{where}: скрипт {script} не исполняемый")
        m = re.match(r"\s*(?:workspace|move-node-to-workspace)\s+(\S+)", c)
        if m and m.group(1) not in persistent and m.group(1) not in ("next", "prev"):
            warns.append(f"{where}: воркспейс `{m.group(1)}` не входит в persistent-workspaces")

    try:
        sheet = Path(args.sheet).read_text()
    except OSError as e:
        warns.append(f"шпаргалка не прочитана: {e}")
        sheet = None

    if sheet is not None:
        kbd = set()
        for m in re.finditer(r"<kbd>(.*?)</kbd>", sheet, re.S):
            kbd.update(m.group(1).split())
        boxes = set(re.findall(r'<b class="k">([^<]+)</b>', sheet))

        for w in persistent:
            if w not in boxes:
                warns.append(f"воркспейс {w} (persistent-workspaces) не показан в шпаргалке")

        for key, value in modes.get("main", {}).get("binding", {}).items():
            if not key.startswith(HYPER):
                continue
            name = key[len(HYPER):]
            label = KEY_LABEL.get(name, name.upper())
            if label not in kbd:
                warns.append(f"Hyper+{label} ({'; '.join(commands(value))}) нет в шпаргалке")

        for name in modes:
            if name == "main":
                continue
            for key, value in modes["main"].get("binding", {}).items():
                if any(c.strip() == f"mode {name}" for c in commands(value)):
                    parts = [p for p in key.split("-")]
                    last = KEY_LABEL.get(parts[-1], parts[-1].upper())
                    if last not in kbd:
                        warns.append(f"вход в режим {name} ({key}) не описан в шпаргалке")

    if not args.no_git:
        try:
            staged = subprocess.run(["git", "-C", str(ROOT), "diff", "--cached", "--name-only"],
                                    capture_output=True, text=True, check=True).stdout.split()
            if ".aerospace.toml" in staged and "docs/aerospace-cheatsheet.html" not in staged:
                warns.append("конфиг изменён в этом коммите, а шпаргалка нет: проверь, не устарела ли она")
        except (subprocess.CalledProcessError, FileNotFoundError):
            pass

    for e in errors:
        print(f"✘ {e}", file=sys.stderr)
    for w in warns:
        print(f"⚠ {w}", file=sys.stderr)
    if errors:
        print("Коммит остановлен: исправь ошибки конфига (иначе AeroSpace его не загрузит).", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
