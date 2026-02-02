{ pkgs, ... }:
{
  services.xserver.enable = true;

  services.displayManager.lightdm.enable = true;
  services.desktopManager.xfce.enable = true;

  environment.systemPackages = with pkgs; [
    xfce.thunar
  ];
}
