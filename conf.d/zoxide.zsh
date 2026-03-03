#### https://github.com/ajeetdsouza/zoxide

if ! command -v zoxide &> /dev/null; then
    echo "zoxide is not installed. Please install it to use the directory navigation."
    return
fi

echo "Loading zoxide..."

eval "$(zoxide init zsh)"
# 対話シェルのときのみ有効にする
# claude code内からの呼び出しに失敗するため
# https://github.com/anthropics/claude-code/issues/2407
if [[ $- == *i* ]]; then
  eval "$(zoxide init zsh --cmd cd)"
fi
