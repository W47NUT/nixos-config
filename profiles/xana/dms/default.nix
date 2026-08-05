{ pkgs, ... }:

let
  syncXanaDmsVisualSettings = pkgs.writeShellApplication {
    name = "sync-xana-dms-visual-settings";

    runtimeInputs = with pkgs; [
      coreutils
      jq
    ];

    text = ''
      set -euo pipefail

      config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/DankMaterialShell"
      settings="$config_dir/settings.json"
      baseline="${./visual-settings.json}"

      mkdir -p "$config_dir"

      temporary_file="$(mktemp "$config_dir/.settings.json.XXXXXX")"
      trap 'rm -f "$temporary_file"' EXIT

      if [[ -s "$settings" ]] && jq empty "$settings" >/dev/null 2>&1; then
        jq -S -s '.[0] * .[1]' \
          "$settings" \
          "$baseline" \
          > "$temporary_file"
      else
        jq -S . \
          "$baseline" \
          > "$temporary_file"
      fi

      chmod 0600 "$temporary_file"
      mv "$temporary_file" "$settings"

      trap - EXIT

      echo "Applied Xana visual settings to $settings"
    '';
  };
in
{
  systemd.user.services = {
    xana-dms-settings = {
      description = "Apply Xana visual settings to Dank Material Shell";
      before = [ "dms.service" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${syncXanaDmsVisualSettings}/bin/sync-xana-dms-visual-settings";
      };
    };

    dms = {
      wants = [ "xana-dms-settings.service" ];
      after = [ "xana-dms-settings.service" ];
    };
  };
}
