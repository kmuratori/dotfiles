# Environment variables for login shells (bash)
# Default programs
export EDITOR="hx"
export TERMINAL="alacritty"
export BROWSER="qutebrowser"
export BROWSER2="firefox"
export DISPLAY=:0

# XDG base dirs
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Path additions
export PATH="/opt/bin:$HOME/.local/bin:$XDG_CONFIG_HOME/scripts:$HOME/.local/share/cargo/bin:$PATH"

# Language/workspace dirs
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export GOPATH="$XDG_DATA_HOME/go"
export GOBIN="$GOPATH/bin"

# History + misc
export LESSHISTFILE="$XDG_CACHE_HOME/less_history"
export PYTHON_HISTORY="$XDG_DATA_HOME/python/history"

# App/config locations
export XINITRC="$XDG_CONFIG_HOME/x11/xinitrc"
export XPROFILE="$XDG_CONFIG_HOME/x11/xprofile"
export XRESOURCES="$XDG_CONFIG_HOME/x11/xresources"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc-2.0"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export FFMPEG_DATADIR="$XDG_CONFIG_HOME/ffmpeg"
export WINEPREFIX="$XDG_DATA_HOME/wineprefixes/default"
export VIMINIT='set runtimepath^=~/.config/vim runtimepath+=~/.config/vim/after'
export VIMDATA=~/.local/share/vim
export GIT_CONFIG_GLOBAL="$HOME/.config/git/config"
# XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
export INPUTRC="$XDG_CONFIG_HOME/inputrc"
export WALLPAPERS_PATH="$HOME/.local/share/wallpapers"
export QT_QPA_PLATFORMTHEME="qt5ct"
# export QT_STYLE_OVERRIDE="Kvantum"
