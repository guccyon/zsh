# gh alias registration
if command -v gh >/dev/null 2>&1; then
  _gh_ensure_alias() {
    local name="$1"
    shift
    if ! gh alias list 2>/dev/null | grep -q "^${name}:"; then
      gh alias set "$name" "$@" >/dev/null 2>&1
    fi
  }

  _gh_ensure_alias co pr checkout
  _gh_ensure_alias pv pr view -w

  unfunction _gh_ensure_alias
fi
