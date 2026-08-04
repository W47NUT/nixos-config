{ ... }:

{
	imports = [
		./hardware-configuration.nix
		../../../profiles/xana
	];

	networking.hostName = "xana";

	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	system.stateVersion = "26.05";
}
