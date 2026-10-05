{ ... }:

{
  # Hand-packaged apps (see ../../packages), reachable as pkgs.local.<name>.
  flake.overlays.local = final: _prev: {
    local = {
      claude-desktop = final.callPackage ../../packages/claude-desktop.nix { };
      chatgpt-linux = final.callPackage ../../packages/chatgpt-linux.nix { };
      helium = final.callPackage ../../packages/helium.nix { };
      anifetch = final.callPackage ../../packages/anifetch.nix { };
    };
  };
}
