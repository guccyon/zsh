CONFIG_DIR="$HOME/.config/zsh"

echo "Loading Antidote plugin manager..."

#### Plugin
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load $CONFIG_DIR/.zsh_plugins.txt

