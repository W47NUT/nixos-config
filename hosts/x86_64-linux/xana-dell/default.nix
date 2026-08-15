{ ... }:

{
	imports = [
		./hardware-configuration.nix
		../../../profiles/xana
	];

	networking.hostName = "xana-dell";

  services.tailscale.enable = true;

	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	system.stateVersion = "26.05";
}
