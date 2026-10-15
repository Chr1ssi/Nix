{ ... }:

{
  # Hand-packaged apps (see ../../packages), reachable as pkgs.local.<name>.
  flake.overlays.local = final: _prev: {
    local = {
      claude-desktop = final.callPackage ../../packages/claude-desktop.nix { };
      slot-nord-dark-colorize-icons =
        final.callPackage ../../packages/slot-nord-dark-colorize-icons.nix
          { };
    };
  };
}
