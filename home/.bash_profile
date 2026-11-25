# Load environment and interactive shell settings
# Load environment vars (from .profile)
if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi

# Load interactive Bash settings
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

if [ -f "$HOME/.config/shell/alias" ]; then
    . "$HOME/.config/shell/alias"
fi
