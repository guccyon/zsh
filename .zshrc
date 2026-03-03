##### Language/Editor #####
export LANG=en_US.UTF-8
export EDITOR=vim

# Load conf.d/*.zsh
CONFD_DIR="$HOME/.config/zsh/conf.d"
for f in "$CONFD_DIR"/*.zsh(N); do
  if [ -r "$f" ] && [ -f "$f" ]; then
    source "$f"
  fi
done

#### History search with arrow keys #####
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

#### Make word deletion stop at path separators, etc.
WORDCHARS=''

clear
