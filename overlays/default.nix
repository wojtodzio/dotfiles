# Auto-load all overlay files in this directory
# Returns a list of overlay functions
let
  # Get all .nix files in this directory except default.nix
  overlayFiles = builtins.filter (
    name: name != "default.nix" && builtins.match ".*\\.nix" name != null
  ) (builtins.attrNames (builtins.readDir ./.));

  # Import each overlay file as an overlay function
  overlays = map (name: import (./. + "/${name}")) overlayFiles;
in
overlays
