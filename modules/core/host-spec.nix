# Host metadata flags for conditional configuration
{ lib, ... }:

{
  options.hostSpec = {
    isDarwin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this is a macOS (Darwin) system";
    };
    isServer = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this is a server (headless) system";
    };
    hasGui = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this system has a GUI";
    };
    enableEmacs = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Emacs editor";
    };
    enableNeovim = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Neovim editor";
    };
    enableYazi = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Yazi file manager";
    };
  };
}
