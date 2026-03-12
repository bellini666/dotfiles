#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROFILE_PATH="${SCRIPT_DIR}/agent.sb"

usage() {
  echo "Usage: run-sandboxed.sh [--workdir=/path] <command> [args...]" >&2
  exit 1
}

# Parse --workdir flag
workdir=""
while [[ $# -gt 0 ]]; do
  case "$1" in
  --workdir=*)
    workdir="${1#--workdir=}"
    shift
    ;;
  --workdir)
    workdir="${2:-}"
    shift 2
    ;;
  *)
    break
    ;;
  esac
done

[[ $# -eq 0 ]] && usage

# Resolve effective workdir: explicit flag > git root > pwd
if [[ -z "$workdir" ]]; then
  workdir="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
fi
workdir="$(cd "$workdir" && pwd -P)"

# Build ancestor literal rules for the resolved workdir.
# Walk dirname up to / so readdir() works on every parent.
build_ancestor_literals() {
  local dir="$1"
  local ancestors=""
  local parent
  parent="$(dirname "$dir")"
  while [[ "$parent" != "/" && "$parent" != "$dir" ]]; do
    ancestors="${ancestors}    (literal \"${parent}\")
"
    dir="$parent"
    parent="$(dirname "$dir")"
  done
  echo "$ancestors"
}

ancestor_rules="$(build_ancestor_literals "$workdir")"
ancestor_block=""
if [[ -n "$ancestor_rules" ]]; then
  ancestor_block=";; Workdir ancestor literals
(allow file-read*
${ancestor_rules})
"
fi

# Assemble the profile: inject ancestors before the workdir block and replace the token
tmpfile="$(mktemp -t sandbox-profile.XXXXXX)"
trap 'rm -f "$tmpfile"' EXIT

# 1. Inject ancestor block before __WORKDIR_BLOCK_START__
# 2. Replace __SAFEHOUSE_WORKDIR__ with the resolved workdir
if [[ -n "$ancestor_block" ]]; then
  # Write ancestor block to a temp file for sed r command
  ancestor_tmpfile="$(mktemp -t sandbox-ancestors.XXXXXX)"
  trap 'rm -f "$tmpfile" "$ancestor_tmpfile"' EXIT
  printf '%s' "$ancestor_block" >"$ancestor_tmpfile"

  sed -e "/__WORKDIR_BLOCK_START__/{
r $ancestor_tmpfile
}" -e "s|__SAFEHOUSE_WORKDIR__|${workdir}|g" "$PROFILE_PATH" >"$tmpfile"
else
  sed "s|__SAFEHOUSE_WORKDIR__|${workdir}|g" "$PROFILE_PATH" >"$tmpfile"
fi

sandbox-exec -f "$tmpfile" "$@"
