{ pkgs, ... }:
{
  # Common boot settings shared across all hosts
  boot.initrd.compressor = "zstd";
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.loader.timeout = 25;
}
