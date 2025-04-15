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

    nvf = {
      type = "github";
      owner = "NotAShelf"; # my buddy raf
      repo = "nvf";
      ref = "main";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nixos-hardware,
    nvf,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages."${system}";
  in {
    nixosConfigurations.xana = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = { inherit inputs self system; };

      modules = [ ./configuration.nix ];
    };

    packages."${system}".nvf  = (inputs.nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [ ./nvf.nix ];
    }).neovim;
  };
}
