# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (c) 2025 midischwarz12
# Copyright (c) 2025 W47NUT

{
  pkgs,
  inputs,
  lib,
  self,
  ...
}:
{
  imports = [
    inputs.dms.nixosModules.dank-material-shell
    inputs.dank-greeter.nixosModules.default
    ./dms
  ];

  networking = {
    networkmanager.enable = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  time.timeZone = "America/New_York";

  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  services = {
    xserver = {
      enable = true;

      xkb = {
        layout = "us";
        variant = "";
      };
    };

    displayManager = {
      defaultSession = "niri";
    };

    upower.enable = true;


    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };

    printing.enable = true;

    openssh.enable = true;

    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.ControllerMode = "bredr";
    };
  };

  security = {
    rtkit.enable = true;

    apparmor = {
      enable = true;
      policies = { };
    };

    # view audit logs with `ausearch` or `aureport`
    audit = {
      enable = true;
      rules = [ ];
    };
    auditd.enable = true;

    # backend for password popup for authenticating priveleged tasks
    polkit.enable = true;
  };

  virtualisation.docker.enable = true;

  documentation = {
    enable = true;
    man.enable = true;
    nixos.enable = true;
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
  };

  environment = {
    sessionVariables = {
      BROWSER = "brave";
      DEFAULT_BROWSER = "brave";
      QS_ICON_THEME = "Papirus-Dark";

      EDITOR = "vi";
      PAGER = "vi +Man!";
      MANPAGER = "vi +Man!";

      # nixpkgs
      NIXOS_OZONE_WL = "1";
      NIXOS_XDG_OPEN_USE_PORTAL = "1";

      # wlroots: https://github.com/swaywm/wlroots/blob/master/docs/env_vars.md
      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_RENDERER = "vulkan";
      WLR_DRM_NO_ATOMIC = "1";

      # QT
      QT_QPA_PLATFORM = "wayland";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

      # GTK
      GTK_USE_PORTAL = "1";

      # SDL
      SDL_VIDEODRIVER = "wayland";

      # Clutter
      CLUTTER_BACKEND = "wayland";

      # Mozilla
      MOZ_ENABLE_WAYLAND = "1";
    };

    shellAliases = {
      cat = "${pkgs.bat}/bin/bat --style=plain --theme=ansi --pager=never";
      g = "${pkgs.git}/bin/git";

      tree = "${pkgs.eza}/bin/eza --color always --icons --hyperlink --group-directories-first --tree";
      l = "${pkgs.eza}/bin/eza --color always --icons --hyperlink";
      l1 = "${pkgs.eza}/bin/eza --color always --icons --hyperlink --group-directories-first --tree --level=1";
      l2 = "${pkgs.eza}/bin/eza --color always --icons --hyperlink --group-directories-first --tree --level=2";
      l3 = "${pkgs.eza}/bin/eza --color always --icons --hyperlink --group-directories-first --tree --level=3";
      ll = "${pkgs.eza}/bin/eza --color always --icons --hyperlink --group-directories-first --tree --level=1 --long --header --inode --links";
      la = "${pkgs.eza}/bin/eza --color always --icons --hyperlink --group-directories-first --tree --level=1 --long --header --inode --links --all";

      rebuild = "${pkgs.nh}/bin/nh os -v switch \"$HOME/flake\"";
      repl = "${pkgs.nh}/bin/nh os -v repl \"$HOME/flake\"";
      build-vm = "${pkgs.nh}/bin/nh os -v switch \"$HOME/flake\"";
      clean = "${pkgs.nh}/bin/nh clean all";
      dry-build = "nixos-rebuild -v --use-remote-sudo  dry-build --flake \"$HOME/flake\"";
    };

    systemPackages = with pkgs; [
      papirus-icon-theme
      hicolor-icon-theme
      tailscale
      man-pages
      man-pages-posix
      git
    gh
      (inputs.atomic-vim.lib.${pkgs.stdenv.hostPlatform.system}.mkAtomicVim ./atomicVim.nix)
      nh
      starship
      wallust
      jj
    ];
  };

  users.users.w47nut = {
    isNormalUser = true;
    description = "W47NUT";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      fastfetch
      git
    gh
      sshx
      bitwarden-desktop
      vesktop
      signal-desktop
      telegram-desktop
      element-desktop
      kitty
      fuzzel
      ranger
      brave
      hyprpicker
      swaynotificationcenter
      nautilus
      avizo
      swaylock
      lsd
      vivid
      awww
      unzip
      ueberzugpp
      obsidian
      spotify
      btop
      wl-clipboard
      cliphist
      protonmail-desktop
      starship
      wallust

      # pick which you like most
      bluez
      blueman
      bluetuith

      bibata-cursors
      glib
    ];
  };

  systemd.user.tmpfiles.users."w47nut".rules = [
    "L+ %h/.local/share/fonts       - - - - /run/current-system/sw/share/X11/fonts"
    "L+ %h/.config/waybar - - - - ${self + "/dotfiles/waybar"}"
    "d %h/.config/niri 0700 - - -"
    "d %h/.config/niri/dms 0700 - - -"
    "L+ %h/.config/niri/config.kdl - - - - ${self + "/dotfiles/niri/config.kdl"}"
    "L+ %h/.config/starship.toml - - - - ${self + "/dotfiles/starship.toml"}"
    "L+ %h/.config/btop - - - - ${self + "/dotfiles/btop"}"
    "d %h/.config/kitty 0700 - - -"
    "L+ %h/.config/kitty/kitty.conf - - - - ${self + "/dotfiles/kitty/kitty.conf"}"
    "f %h/.config/kitty/xana-wallust.conf 0600 - - -"
    "d %h/.config/wallust 0700 - - -"
    "d %h/.config/wallust/templates 0700 - - -"
    "L+ %h/.config/wallust/wallust.toml - - - - ${self + "/dotfiles/wallust/wallust.toml"}"
    "L+ %h/.config/wallust/templates/kitty.conf - - - - ${self + "/dotfiles/wallust/templates/kitty.conf"}"
    "L+ %h/.config/.zshrc - - - - ${self + "/dotfiles/.zshrc"}"
    "L+ %h/.gitconfig - - - - ${self + "/dotfiles/.gitconfig"}"
    "d %h/.local/share/icons 0755 - - -"
    "L+ %h/.local/share/icons/xana-evolution-emblem.svg - - - - ${self + "/assets/icons/xana-evolution-emblem.svg"}"
    "d %h/.local/share/wallpapers 0755 - - -"
    "L+ %h/.local/share/wallpapers/xana - - - - ${self + "/assets/wallpapers/xana"}"
  ];

  systemd.user.services."xana-wallust-sync" = {
    description = "Sync Kitty colors with the current DMS wallpaper";
    after = [ "graphical-session.target" "dms.service" ];
    wants = [ "dms.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = let
        script = pkgs.writeShellScript "xana-wallust-sync" ''
          set -eu
          export PATH=/run/current-system/sw/bin:$PATH

          state_dir="$HOME/.local/state/xana"
          last_file="$state_dir/last-wallpaper"
          mkdir -p "$state_dir"

          wallpaper="$(
            dms ipc call wallpaper get 2>/dev/null \
            | grep -Eo '/[^[:cntrl:]]+\.(png|jpg|jpeg|webp|bmp)' \
            | tail -n 1
          )"

          [ -n "$wallpaper" ] || exit 0
          [ -f "$wallpaper" ] || exit 0

          previous="$(cat "$last_file" 2>/dev/null || true)"
          if [ "$previous" = "$wallpaper" ] && [ -s "$HOME/.config/kitty/xana-wallust.conf" ]; then
            exit 0
          fi

          wallust run "$wallpaper" --saturation 45
          printf '%s\n' "$wallpaper" > "$last_file"

          kitty @ --to unix:/tmp/kitty-xana set-colors --all --configured "$HOME/.config/kitty/xana-wallust.conf" || true
        '';
      in "${script}";
    };
  };

  systemd.user.timers."xana-wallust-sync" = {
    description = "Poll DMS wallpaper changes for Kitty recoloring";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "20s";
      OnUnitActiveSec = "15s";
      Unit = "xana-wallust-sync.service";
      Persistent = true;
    };
  };

  programs = {
    niri.enable = true;
    neovim.enable = true;
    thunar.enable = true;
    starship.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      histSize = 10000;
      promptInit = "";
    };

    dms-greeter = {
      enable = true;
      compositor.name = "niri";
      configHome = "/home/w47nut";
      logs.save = true;
    };
    dank-material-shell = {


      enable = true;
      systemd.enable = true;
    };
  };

  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config.common.default = "*";
      extraPortals = with pkgs; [ xdg-desktop-portal-gnome ];
    };

    mime.enable = true;
    icons.enable = true;
    menus.enable = true;
    autostart.enable = true;
    sounds.enable = true;
    terminal-exec.enable = true;
  };

  nixpkgs = {
    config.allowUnfree = true;

    # Bitwarden Desktop currently depends on this EOL Electron release in
    # NixOS 26.05. Remove the exception once nixpkgs updates Bitwarden.
    config.permittedInsecurePackages = [ "electron-39.8.10" ];
  };

  fonts = {
    enableDefaultPackages = true;
    packages =
      with pkgs;
      [
        liberation_ttf
        ubuntu-classic

        noto-fonts
        noto-fonts-cjk-serif
        noto-fonts-cjk-sans

        inter-nerdfont
      ]
      ++ builtins.filter lib.isDerivation (lib.attrValues pkgs.nerd-fonts);

    fontDir = {
      enable = true;
      decompressFonts = true;
    };

    fontconfig = {
      enable = true;

      # `fc-list | grep "<font-name>"`
      # `fc-match "<font-name>"`
      defaultFonts = {
        serif = [
          "NotoSerif Nerd Font"
          "Noto Serif"
          "Noto Serif CJK SC"
          "Noto Serif CJK JP"
          "Noto Serif CJK KR"
          "Noto Serif CJK TC"
          "Noto Serif CJK HK"
        ];
        sansSerif = [
          "Inter Nerd Font"
          "NotoSans Nerd Font"
          "Noto Sans"
          "Noto Sans CJK SC"
          "Noto Sans CJK JP"
          "Noto Sans CJK KR"
          "Noto Sans CJK TC"
          "Noto Sans CJK HK"
        ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };

      hinting = {
        enable = true;
        style = "medium";
      };

      localConf =
        builtins.replaceStrings
          [ "</fontconfig>" ]
          [
            ''
                <alias>
                  <family>Inter</family>
                  <prefer><family>Inter Nerd Font</family></prefer>
                </alias>
              </fontconfig>
            ''
          ]
          (
            builtins.readFile (
              pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/v3.2.1/10-nerd-font-symbols.conf";
                hash = "sha256-ZgHkMcXEPYDfzjdRR7KX3ws2u01GWUj48heMHaiaznY=";
              }
            )
          );
    };
  };
}
