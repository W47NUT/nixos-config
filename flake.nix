{
  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-24.11";
    };

    nixos-hardware = {
      type = "github";
      owner = "NixOS";
      repo = "nixos-hardware";
      ref = "master";
    };

    atomic-vim = {
      type = "git";
      url = "https://codeberg.org/midischwarz/atomic-vim";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.xana = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs self system; };
        modules = [ ./configuration.nix ];
      };

      formatter."${system}" = pkgs.writeShellApplication {
        name = "lint";
        runtimeInputs = with pkgs; [
          nixfmt-rfc-style
          deadnix
          statix
          shellcheck
          fd
        ];
        text = ''
          fd '.*\.nix' . -x statix fix -- {} \; -x deadnix -e -- {} \; -x nixfmt {} \;
          fd '.*\.sh' . -x shellcheck {} \;
        '';
      };
    };
}
