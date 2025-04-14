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
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nixos-hardware,
    ...
  }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations.xana = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = { inherit inputs self; };

      modules = [
        ./configuration.nix
      ];
    };
  };
}
