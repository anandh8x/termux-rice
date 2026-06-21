# Termux Rice

This is my personal Termux setup.

It is built for my own workflow, preferences, and usage. It is not meant
to be a universal Termux framework or a full dotfiles system. If you use it on
another device, read the scripts first and adjust anything that does not match
your setup.

The goal is simple: keep Termux clean, readable, and comfortable without adding
heavy prompt frameworks or lots of extra tools.

## Included

- Base16 Brewer terminal colors
- Compact colored Bash prompt
- Better Bash history
- `bash-completion` setup
- Colored `ls`
- Navigation aliases: `ll`, `la`, `..`, `...`, `c`, `reload`
- Termux starts in `/storage/emulated/0`
- Scrollback set to `8000`
- Steady bar cursor
- Black Termux drawer/dialog UI
- Small terminal margins
- Custom extra keys:

```text
ESC  /     -    TAB   UP    DRAWER  PASTE
HOME CTRL  ALT  LEFT  DOWN  RIGHT   KEYBOARD
```

## Install

```sh
git clone https://github.com/anandh8x/termux-rice ~/termux-rice
cd ~/termux-rice
bash install.sh
```

The installer backs up touched files to:

```sh
~/.termux-rice-backup/<timestamp>/
```

It installs `bash-completion` if that package is missing.

## Uninstall

```sh
cd ~/termux-rice
bash uninstall.sh
```

The uninstaller removes the marked Bash block, removes the theme file, comments
the Termux properties applied by this repo, and leaves backups in place.

## Files

- `bash/bashrc.termux-rice`: Bash config block appended by the installer
- `termux/colors.properties`: Base16 Brewer colors
- `termux/termux.properties.snippet`: Termux settings applied by the installer
- `install.sh`: apply this rice
- `uninstall.sh`: remove this rice
