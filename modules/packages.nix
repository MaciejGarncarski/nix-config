{
  pkgs,
  config,
  lib,
  ...
}:
{
  programs = {
    firefox.enable = false; # Firefox is not installed by default
    dconf.enable = lib.mkDefault (config.custom.gui.enable or false);
    fuse.userAllowOther = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    corefonts
    monaspace
    fira-code
    fira-code-symbols
  ];

  environment.systemPackages =
    with pkgs;
    [
      docker-compose
      btop
      killall
      lshw
      fastfetch
      unrar
      unzip
      wget
      ffmpeg # Video processing
      imagemagick # Image processing
      python3 # Required for Node.js ./configure
      gcc # Required for compiling native modules
      gnumake # Required for building
      pkg-config # Helps find libraries
    ]
    ++ lib.optionals (config.custom.gui.enable or false) [
      libnotify
      vlc # Media player
      easyeffects # Audio effects processor
      ytmdl
      onlyoffice-desktopeditors
      obsidian
      bruno
      ladybird
      google-chrome
      (pkgs.google-chrome.override {
        commandLineArgs = [
          "--password-store=basic"
          "--enable-features=UseOzonePlatform"
          "--ozone-platform=wayland"
        ];
      })
    ];

  # nix-ld for unpached libraries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
    libxcrypt-legacy
  ];

}
