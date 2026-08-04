# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (c) 2025 midischwarz12
# Copyright (c) 2025 W47NUT

{
  imports = [
    # Hardware, boot, and filesystems are specific to this Yoga.
    ./hardware-configuration.nix

    # Applications and other machine-independent Xana settings.
    ../../../profiles/xana
  ];

  networking.hostName = "xana";

  # Keep this at the release used when this Yoga was first installed.
  system.stateVersion = "25.05";
}
