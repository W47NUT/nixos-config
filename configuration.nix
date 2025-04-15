{ self, pkgs, system, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  networking = {
    hostName = "xana";
    networkmanager.enable = true;
  };

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
      displayManager.gdm.enable = true;

      xkb = {
        layout = "us";
        variant = "";
      };
    };

    # bluetooth client
    blueman.enable = true;

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
      authKeyFile = "/etc/tailscale-auth.key";
      useRoutingFeatures = "client";
      extraSetFlags = [
        "--accept-routes"
      ];
    };
  };

  hardware = {
    pulseaudio.enable = false;

    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.ControllerMode = "bredr";
    };
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
      BROWSER = "firefox";
      DEFAULT_BROWSER = "firefox";

      EDITOR = "nvim";
      
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

    systemPackages = with pkgs; [
      tailscale
      man-pages
      man-pages-posix
    ];
  };

  users.users.w47nut = {
    isNormalUser = true;
    description = "W47NUT";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      self.packages."${system}".nvf

      vscode
      fastfetch
      python314
      git
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
      pywal
      swaynotificationcenter
      nautilus
      avizo
      swaylock
      starship
      lsd
      vivid
      swww
      unzip
      ueberzugpp

      # pick which you like most
      bluez blueman bluetuith

      bibata-cursors
      glib
    ];
  };

  programs = {
    xwayland.enable = true;
    steam.enable = true;
    niri.enable = true;
    waybar.enable = true;
    starship.enable = true;
    neovim.enable = true;

    zsh = {
      enable = true;
      enableBashCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
  };

  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config.common.default = "*";
    };

    mime.enable = true;
    icons.enable = true;
    menus.enable = true;
    autostart.enable = true;
    sounds.enable = true;
    terminal-exec.enable = true;
  };

  systemd.user.tmpfiles.users."w47nut".rules = [
    "L+ %h/.local/share/fonts       - - - - /run/current-system/sw/share/X11/fonts"
  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerdfonts

      liberation_ttf
      ubuntu_font_family

      noto-fonts
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-emoji

      inter-nerdfont
      jetbrains-mono
      dejavu_fonts
      cantarell-fonts
    ];

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
        monospace = [
          "JetBrainsMono Nerd Font"
          "ComicShannsMono Nerd Font"
        ];
        emoji = [ "Noto Color Emoji" ];
      };

      hinting = {
        enable = true;
        style = "medium";
      };

      localConf =
        builtins.replaceStrings [ "</fontconfig>" ]
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


  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
