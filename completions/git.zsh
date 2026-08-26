function _git-worktree-add-remote-branches() {
  local -a branches
  branches=("${(@f)$(git for-each-ref --format='%(refname:strip=3)' refs/remotes/origin 2>/dev/null)}")
  branches=("${(@)branches:#HEAD}")

  (( ${#branches} )) && _describe -t branches 'remote branch' branches
}

function _git-wr() {
  local common_dir base_dir current_worktree record line worktree relative_worktree head branch branch_display
  local -a worktrees descriptions records

  common_dir=$(git rev-parse --git-common-dir 2>/dev/null) || return
  base_dir=$(cd "$common_dir/.." && pwd -P) || return
  current_worktree=$(git rev-parse --show-toplevel 2>/dev/null) || return
  records=( ${(ps.\n\n.)"$(git worktree list --porcelain 2>/dev/null)"} )

  for record in $records; do
    worktree=${${record%%$'\n'*}#worktree }
    [[ "$record" == *$'\nbare'* || "$worktree" == "$current_worktree" || "$worktree" != "$base_dir"/* ]] && continue

    head=""
    branch="(detached HEAD)"
    for line in ${(f)record}; do
      case "$line" in
        HEAD\ *) head=${line#HEAD } ;;
        branch\ refs/heads/*) branch=${line#branch refs/heads/} ;;
      esac
    done

    if [[ "$branch" == "(detached HEAD)" ]]; then
      branch_display="$branch"
    else
      branch_display="[$branch]"
    fi

    relative_worktree=${worktree#"$base_dir/"}
    worktrees+=("$relative_worktree")
    descriptions+=("$branch_display  ${head[1,7]}  $worktree")
  done

  local context state state_descr
  _arguments -C -s -S \
    '(-f --force)'{-f,--force}'[remove a dirty or locked worktree]' \
    '1:worktree path:->worktrees'

  case $state in
    (worktrees)
      (( ${#worktrees} )) && _wanted worktrees expl 'worktree path' compadd -Q -l -d descriptions -a worktrees
    ;;
  esac
}

compdef _git-worktree-add-remote-branches git-worktree-add gwt
compdef _git-wr git-wr
