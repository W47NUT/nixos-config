# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (c) 2025 midischwarz12
# Copyright (c) 2025 W47NUT

{
  pkgs,
  ...
}:

pkgs.writeShellApplication {
  name = "vuln";
  runtimeInputs = with pkgs; [ vulnix ];
  text = ''
    vulnix --system
  '';
}
