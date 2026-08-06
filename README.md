# Xana NixOS Configuration

Personal NixOS flake for the Xana Linux systems.

## Systems

| Flake target | Machine | Purpose |
| --- | --- | --- |
| `xana-dell` | Dell Pro 14 Plus | Primary portable Xana workstation |
| `xana` | Lenovo Yoga | Original Xana system |

Both systems share the main Xana profile while retaining separate hardware configurations.

## Repository layout

```text
assets/                  Wallpapers, icons, and other visual assets
dotfiles/                Niri, Kitty, Starship, and application configuration
hosts/x86_64-linux/      Machine-specific NixOS configurations
lib/                     Shared Nix helper functions
modules/                 Reusable flake and NixOS modules
packages/                Locally packaged software
profiles/xana/           Shared Xana desktop and user configuration
docs/RECOVERY.md         Rollback and rescue instructions
flake.nix                Flake inputs and exported configurations
flake.lock               Pinned dependency versions
```

## Dell rebuild commands

Test the configuration without activating it:

```zsh
cd /etc/nixos-config
sudo nixos-rebuild build --flake .#xana-dell
```

Apply it immediately:

```zsh
cd /etc/nixos-config
sudo nixos-rebuild switch --flake .#xana-dell
```

Install it for the next boot without changing the current session:

```zsh
cd /etc/nixos-config
sudo nixos-rebuild boot --flake .#xana-dell
```

## Health checks

```zsh
git status -sb
systemctl --failed --no-legend
systemctl --user --failed --no-legend
```

A finished checkpoint should have:

- a clean Git working tree;
- no failed system units;
- no failed user units;
- a successful `xana-dell` build.

## Branch policy

- `main` is the known-good daily-use configuration.
- Experimental work belongs on a temporary feature branch.
- A feature branch must build successfully before merging into `main`.
- Stable milestones receive annotated Git tags.

## Recovery

See [`docs/RECOVERY.md`](docs/RECOVERY.md) before repairing a failed build, login screen, or boot configuration.

## License

This repository is distributed under the terms in [`LICENSE`](LICENSE).
