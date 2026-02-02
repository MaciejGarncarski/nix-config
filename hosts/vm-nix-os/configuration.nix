{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/default.nix
    ../../modules/desktop/xfce.nix
  ];

  custom.gui.enable = true;
  networking.hostName = "mcg-vm";

  # Bootloader configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
}
