{ pkgs, inputs, ... }:

let
  patchXanaBattery = pkgs.writeText "patch-xana-battery.py" ''
    from pathlib import Path
    import sys

    path = Path(sys.argv[1])
    text = path.read_text()

    old = """        readonly property color fillColor: {
                if (!BatteryService.batteryAvailable)
                    return Theme.surfaceVariant;
                if (pill.lowState)
                    return Theme.error;
                return Theme.primary;
            }"""

    new = """        readonly property color fillColor: {
                if (!BatteryService.batteryAvailable)
                    return Theme.surfaceVariant;
                if (pill.level <= 10)
                    return "#ef4444";
                if (pill.level <= 20)
                    return "#f59e0b";
                return "#22c55e";
            }"""

    matches = text.count(old)

    if matches != 1:
        raise SystemExit(
            f"Expected exactly one battery fillColor block; found {matches}."
        )

    path.write_text(text.replace(old, new, 1))
  '';

  xanaDmsShell = (inputs.dms.lib.mkDmsShell pkgs).overrideAttrs (oldAttrs: {
    postInstall = (oldAttrs.postInstall or "") + ''
      battery_qml="$out/share/quickshell/dms/Modules/DankBar/Widgets/Battery.qml"

      if [[ ! -f "$battery_qml" ]]; then
        echo "Battery.qml was not installed at $battery_qml" >&2
        find "$out/share/quickshell/dms" \
          -iname "Battery.qml" \
          -print >&2 || true
        exit 1
      fi

      chmod u+w "$battery_qml"

      ${pkgs.python3}/bin/python3 \
        ${patchXanaBattery} \
        "$battery_qml"
    '';
  });

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
  programs.dank-material-shell.package = xanaDmsShell;

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
