function _git-worktree-add-remote-branches() {
  local -a branches
  branches=("${(@f)$(git for-each-ref --format='%(refname:strip=3)' refs/remotes/origin 2>/dev/null)}")
  branches=("${(@)branches:#HEAD}")

  (( ${#branches} )) && _describe -t branches 'remote branch' branches
}

function _git-wr() {
  local current_worktree record line worktree branch
  local -a branches descriptions records

  current_worktree=$(git rev-parse --show-toplevel 2>/dev/null)
  records=( ${(ps.\n\n.)"$(git worktree list --porcelain 2>/dev/null)"} )

  for record in $records; do
    worktree=${${record%%$'\n'*}#worktree }
    branch=""

    for line in ${(f)record}; do
      if [[ $line == branch\ refs/heads/* ]]; then
        branch=${line#branch refs/heads/}
        break
      fi
    done

    [[ -z "$branch" || "$worktree" == "$current_worktree" ]] && continue
    branches+=("$branch")
    descriptions+=("$worktree")
  done

  local context state state_descr line
  _arguments -C -s -S \
    '(-f --force)'{-f,--force}'[remove a dirty or locked worktree]' \
    '1:worktree branch:->branches'

  case $state in
    (branches)
      (( ${#branches} )) && _wanted branches expl 'worktree branch' compadd -Q -d descriptions -a branches
    ;;
  esac
}

compdef _git-worktree-add-remote-branches git-worktree-add gwt
