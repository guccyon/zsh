# ghq get を拡張し、remote-tracking branch を持つ bare + worktree 構成で自動セットアップする関数
# 使い方: ghqb guccyon/cornix
ghqb() {
  local target=$1
  if [[ -z "$target" ]]; then
    echo "Usage: ghqb <repository>"
    return 1
  fi

  # ghq のディレクトリ規約に合わせて保存先を決定する。
  local root_dir
  root_dir=$(command ghq root) || return 1

  # URL や owner/repository 指定から "owner/repository" を抽出する。
  local clean_target
  clean_target=$target
  clean_target=${clean_target#https://github.com/}
  clean_target=${clean_target#http://github.com/}
  clean_target=${clean_target#ssh://git@github.com/}
  clean_target=${clean_target#git@github.com:}
  clean_target=${clean_target#github.com/}
  clean_target=${clean_target%.git}

  if [[ "$clean_target" != */* ]]; then
    echo "Error: Specify a GitHub repository as owner/repository or a GitHub URL"
    return 1
  fi

  local remote_url
  case "$target" in
    http://*|https://*|ssh://*|git@*) remote_url=$target ;;
    *) remote_url="https://github.com/$clean_target.git" ;;
  esac

  local base_dir="$root_dir/github.com/$clean_target"
  local bare_git_dir="$base_dir/.bare"

  if [[ -e "$base_dir" ]]; then
    echo "Error: Destination already exists: $base_dir"
    return 1
  fi

  # bare clone は refs/heads/* に直接取得して remote-tracking branch を作らない。
  # 共有 Git ディレクトリを初期化して fetch refspec を設定することで、通常 clone と同じ
  # refs/remotes/origin/* を維持しつつ worktree を使えるようにする。
  echo "Initializing shared Git directory..."
  mkdir -p "$(dirname "$base_dir")" || return 1
  git init --bare "$bare_git_dir" || return 1
  git -C "$bare_git_dir" remote add origin "$remote_url" || return 1
  git -C "$bare_git_dir" config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*' || return 1

  echo "Fetching remote branches..."
  git -C "$bare_git_dir" fetch --prune origin || return 1
  git -C "$bare_git_dir" remote set-head origin --auto >/dev/null 2>&1

  # origin/HEAD からデフォルトブランチを判定する。
  local default_branch
  default_branch=$(git -C "$bare_git_dir" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
  default_branch=${default_branch#origin/}
  if [[ -z "$default_branch" ]]; then
    echo "Error: Could not determine the default branch for $remote_url"
    return 1
  fi

  # 初期 worktree には origin のデフォルトブランチを追跡するローカルブランチを作成する。
  echo "Creating initial worktree ($default_branch)..."
  git -C "$bare_git_dir" worktree add --track -b "$default_branch" "$base_dir/$default_branch" "origin/$default_branch" || return 1

  cd "$base_dir/$default_branch" || return
  echo "Done! Moved to $base_dir/$default_branch"
}

# ghq コマンドのラッパー関数
ghq() {
  if [[ "$1" == "get" && -n "$2" && "$2" != --* ]]; then
    shift # "get" を取り除く
    ghqb "$@"
  else
    command ghq "$@"
  fi
}
