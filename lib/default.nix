# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (c) 2025 midischwarz12
# Copyright (c) 2025 W47NUT

_:

{
  ls =
    path:
    let
      paths = builtins.readDir path;
    in
    builtins.filter (name: paths.${name} == "directory") (builtins.attrNames paths);
}
