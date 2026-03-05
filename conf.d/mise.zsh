if ! command -v mise &> /dev/null; then
    echo "mise is not installed. Please install it to use the environment management."
    return
fi

eval "$(mise activate zsh)"
