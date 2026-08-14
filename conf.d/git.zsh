function git-worktree-add() {
  local branch=$1
  if [[ -z "$branch" ]]; then
    echo "Usage: gwt <branch-name>"
    return 1
  fi

  local common_dir
  common_dir=$(git rev-parse --git-common-dir 2>/dev/null)
  if [[ -z "$common_dir" ]]; then
    echo "Error: Not in a git repository"
    return 1
  fi

  local base_dir
  base_dir=$(cd "$common_dir/.." && pwd)
  local target_dir="$base_dir/$branch"

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$target_dir" "$branch"
  elif git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    git worktree add --track -b "$branch" "$target_dir" "origin/$branch"
  else
    git worktree add -b "$branch" "$target_dir"
  fi && cd "$target_dir"
}

function peco-git-worktree() {
  # ワークツリー一覧から peco で選択し、1列目のパスを抽出
  local target_dir=$(git worktree list | peco | awk '{print $1}')

  # 選択された場合は、チルダ(~)などのパスを評価して移動
  if [ -n "$target_dir" ]; then
      cd "$(eval echo $target_dir)"
  fi
}

alias gwt=git-worktree-add
alias gwcd=peco-git-worktree
