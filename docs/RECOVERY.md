# Xana Recovery Guide

Recovery instructions for the Dell configuration:

```text
xana-dell
```

Repository:

```text
/etc/nixos-config
```

Stable release tag:

```text
xana-v1.0.0
```

## Important rules

During recovery:

- Do not run `nix-collect-garbage -d`.
- Do not delete old system generations.
- Do not use `sudo git`.
- Do not force-push or rewrite Git history.
- Prefer `nixos-rebuild build` or `boot` before `switch`.

## Roll back from the boot menu

When the current generation does not boot correctly:

1. Restart the laptop.
2. Open the systemd-boot menu.
3. Select an earlier NixOS generation.
4. Boot it normally.

After reaching a working desktop, make that generation the default:

```zsh
sudo /run/current-system/bin/switch-to-configuration boot
```

## Roll back from a running system

Return to the immediately previous system generation:

```zsh
sudo nixos-rebuild switch --rollback
```

List available generations:

```zsh
sudo nix-env \
  --profile /nix/var/nix/profiles/system \
  --list-generations
```


## Rebuild the stable Git tag

Save unfinished work first:

```zsh
cd /etc/nixos-config

git stash push \
  --include-untracked \
  -m "emergency recovery backup"
```

Fetch and check out the known-good release:

```zsh
git fetch --tags origin
git switch --detach xana-v1.0.0
```

Build it without immediately replacing the running system:

```zsh
sudo nixos-rebuild build --flake .#xana-dell
```

Install it for the next boot:

```zsh
sudo nixos-rebuild boot --flake .#xana-dell
systemctl reboot
```

After recovery, return the repository to normal:

```zsh
cd /etc/nixos-config

git switch main
git pull --ffana-dell
systemctl reboot
```

After recovery, return the repository to normal-only origin main
```

List saved emergency work:

```zsh
git stash list
```

Do not restore a stash until the machine is working normally.

## Recover from the installer USB

Boot the NixOS installer in UEFI mode.

Mount the installed system:

```zsh
sudo mount /dev/disk/by-label/nixos /mnt

sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/BOOT /mnt/boot
```

Enter the installed system:

```zsh
sudo nixos-enter --root /mnt
```

Inside the installed system:

```zsh
cd /etc/nixos-config

git fetch --tags origin
git switch --detach xana-v1.0.0

nixos-rebuild boot \
  --option sandbox false \
  --flake .#xana-dell
```

Then exit and restart:

```zsh
exit
sudo reboot
```


## Repair from `main`

Use this when GitHub's `main` branch is known to be healthy:

```zsh
cd /etc/nixos-config

git switch main
git pull --ff-only origin main

sudo nixos-rebuild build --flake .#xana-dell
sudo nixos-rebuild switch --flake .#xana-dell
```

## Inspect failures

System services:

```zsh
systemctl --failed
journalctl -b -p warning
```

User-session services:

```zsh
systemctl --user --failed
journalctl --user -b -p warning
```

Dank Material Shell:

```zsh
systemctl --user status dms.service
journalctl --user -u dms.service -b --no-pager
```

DankGreeter and greetd:

```zsh
systemctl status greetd.service
journalctl -u greetd.service -b --no-pager
```

## Confirm recovery

```zsh
cd /etc/nixos-config

git status -sb

systemctl --failed --no-legend
systemctl --user --failed --no-legend

systemctl is-active greetd.service
systemctl --user is-active dms.service
```

Expected core service state:

```text
active
active
```
