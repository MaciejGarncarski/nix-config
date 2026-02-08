{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  # Dependent on flatpaks flake
  services = {

    flatpak = {
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
  };
}
