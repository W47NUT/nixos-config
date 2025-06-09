# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (c) 2025 midischwarz12
# Copyright (c) 2025 W47NUT

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    atomic-vim = {
      type = "git";
      url = "https://codeberg.org/midischwarz12/atomic-vim";
    };

    dix = {
      url = "github:bloxx12/dix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{ withSystem, ... }:
      {
        debug = true;

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];

        imports =
          let
            inherit (builtins)
              readDir
              attrNames
              ;
          in
          map (n: ./. + "/modules/${n}") (attrNames (readDir ./modules));

        perSystem =
          {
            pkgs,
            lib,
            inputs',
            self',
            ...
          }:
          let
            pkgsUnstable = inputs'.nixpkgs-unstable.legacyPackages;
          in
          {
            packages = import (self + "/packages") {
              inherit
                inputs'
                inputs
                self'
                self
                top
                lib
                pkgs
                pkgsUnstable
                ;
            };

            devShells.default = pkgs.callPackage (self + "/shell.nix") { inherit inputs'; };

            formatter = pkgs.writeShellApplication {
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

        flake = {
          lib' = import (self + "/lib") {
            inherit
              self
              inputs
              top
              ;

          };
          nixosConfigurations = import (self + "/hosts") {
            inherit
              self
              inputs
              top
              withSystem
              ;
          };
        };
      }
    );
}
