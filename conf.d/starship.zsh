echo "Loading Starship..."

if ! command -v starship &> /dev/null; then
    echo "Starship is not installed. Please install it to use the prompt."
    return
fi

eval "$(starship init zsh)"
