# Dotfiles

Репозиторий, содержащий переносимые конфигурационные файлы.

## Конфигурация XKB

Чтобы создать символьную в домашней директории, выполните следующую команду:
```bash
export REPO_PATH=/path/to/local-repo
mkdir -p $REPO_PATH
git clone https://github.com/denilai/dotfiles.git $REPO_PATH
ln -s $REPO_PATH/.config/dotfiles/.config/xkb/ ~/.config/xkb
```
