{
  config,
  lib,
  ...
}:
{
  options.custom.gui.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable GUI (desktop environment and GUI applications)";
  };
}
