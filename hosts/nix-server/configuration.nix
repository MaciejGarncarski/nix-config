{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/default.nix
  ];

  # No GUI - headless configuration
  custom.gui.enable = false;
  networking.hostName = "mcg-server";

  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
}
