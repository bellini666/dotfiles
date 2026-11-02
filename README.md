# My personal dotfiles

Feel free to take a look and steal some parts/ideas.

Open an issue if you have any questions, really happy to help the community :)

## Install

```sh
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
MISE_AUTO_ENV=1 mise bootstrap --from https://github.com/bellini666/dotfiles.git --from-dir ~/.dotfiles --yes --force-dotfiles
git -C ~/.dotfiles remote set-url origin git@github.com:bellini666/dotfiles.git
```

Run `bootstrap` from a new shell to update everything. It passes its arguments to `mise bootstrap`, for example `bootstrap --only tools`.
