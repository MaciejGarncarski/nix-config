{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/default.nix
    ../../modules/desktop/plasma.nix
    ../../modules/nvidia.nix
    ../../modules/obs.nix
  ];

  custom.gui.enable = true;
  networking.hostName = "mcg";

  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 2;
  boot.loader.efi.canTouchEfiVariables = true;
}
