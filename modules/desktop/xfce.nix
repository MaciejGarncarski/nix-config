{ pkgs, ... }:
{
  services.xserver.enable = true;

  services.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  environment.systemPackages = with pkgs; [
    xfce.thunar
  ];
}
