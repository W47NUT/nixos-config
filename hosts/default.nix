# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (c) 2025 midischwarz12
# Copyright (c) 2025 W47NUT

{
  self,
  inputs,
  top,
  withSystem,
  ...
}:

let
  inherit (inputs) nixpkgs;
  inherit (self.lib') ls;
  inherit (nixpkgs.lib) nixosSystem;

  systems' = ls (self + "/hosts");
  genSystemPath = system: self + "/hosts/${system}";
  genHosts = system: ls (genSystemPath system);

  genNixos =
    host: system:
    withSystem system (
      {
        self',
        inputs',
        system,
        ...
      }:
      nixosSystem {
        inherit system;
        specialArgs = {
          inherit
            inputs'
            inputs
            self'
            self
            top
            ;
        };
        modules = [
          (self + "/hosts/${system}/${host}")
        ];
      }
    );

  nameValuePair = name: value: { inherit name value; };

  perSystemHostsAttrList =
    system: (map (host: nameValuePair host (genNixos host system)) (genHosts system));

  allHostAttrList = builtins.foldl' (
    acc: system: acc ++ (perSystemHostsAttrList system)
  ) [ ] systems';
in
builtins.listToAttrs allHostAttrList
