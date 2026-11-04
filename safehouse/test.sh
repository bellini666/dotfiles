#!/bin/bash
# Assert the sandbox boundary: `SAFE_ENABLE=keychain safe bash ~/.dotfiles/safehouse/test.sh` from any directory but ~.

# Safehouse only adds Keychain for agent commands, and gh, glab and pup keep tokens there.

# shellcheck source=safehouse/test-lib.sh
source "${DOTFILES_DIR}/safehouse/test-lib.sh"

if [ "$(pwd -P)" = "${HOME}" ]; then
  echo "Run from a directory other than ~: sessions there get full access by design." >&2
  exit 2
fi

for f in .ssh/id_rsa .aws/config .kube/config .config/aws-sso/config.yaml .secret_env.sh; do
  must_fail "head -c1 '${HOME}/${f}'"
done
must_fail "aws-sso version"
must_fail "aws sts get-caller-identity"

# A write that gets through leaves an existing file untouched and removes a new one.
for f in .zshrc .config/mise/config.toml .config/mise/conf.d/.safehouse-probe .mise.toml \
  .local/share/mise/plugins/.safehouse-probe .rustup/toolchains/.safehouse-probe \
  .rustup/settings.toml .cargo/config.toml dev/_tmp/mise.toml; do
  p="${HOME}/${f}"
  if [ -e "${p}" ]; then
    must_fail ": >> '${p}'"
  else
    must_fail "touch '${p}' && rm '${p}'"
  fi
done

while IFS= read -r dir; do
  case "${dir}" in
  "${HOME}"/*) must_fail "p='${dir}/.safehouse-probe.$$'; touch \"\$p\" && rm \"\$p\"" ;;
  esac
done < <(tr ':' '\n' <<<"${PATH}" | sort -u)

must_pass "git ls-remote git@github.com:bellini666/dotfiles.git HEAD"
must_pass "k=\$(mktemp); ssh-add -L | head -1 > \"\$k\"; ssh-keygen -Y sign -U -n git -f \"\$k\" </dev/null; rc=\$?; rm -f \"\$k\"; exit \$rc"
must_pass "gh pr list -R bellini666/dotfiles"
must_pass "docker ps"
must_pass "docker compose version"
must_pass "curl -sfI https://pypi.org"

echo "failures: ${fails}"
[ "${fails}" -eq 0 ]
