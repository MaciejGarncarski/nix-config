{ pkgs, ... }:
{
  services.xserver.enable = true;

  # Plasma (Wayland)
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.kdenlive
    kdePackages.filelight
    ffmpegthumbnailer
  ];

  # remove unused packages
  environment.plasma6.excludePackages = with pkgs; [
    pkgs.kdePackages.konsole
    pkgs.kdePackages.elisa
  ];
}
