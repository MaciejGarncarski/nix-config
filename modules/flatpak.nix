{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
lib.mkIf config.custom.gui.enable {
  # Dependent on flatpaks flake
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];

  services.flatpak = {
    enable = true; # Enable Flatpak

    remotes = lib.mkOptionDefault [
      # mkOptionDefault is merging with current props, not overriding
      {
        name = "beta";
        location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
      }
    ];

    packages = [
      {
        appId = "com.brave.Browser";
        origin = "flathub";
      }
      {
        appId = "com.usebottles.bottles";
        origin = "flathub";
      }
      {
        appId = "fr.handbrake.ghb";
        origin = "flathub";
      }
      {
        appId = "com.github.tchx84.Flatseal";
        origin = "flathub";
      }
    ];

    update.onActivation = true;
  };
}
