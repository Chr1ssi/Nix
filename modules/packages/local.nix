{ inputs, ... }:

{
  # Hand-packaged apps (see ../../packages), reachable as pkgs.local.<name>.
  flake.overlays.local = final: _prev: {
    local = {
      mywm-smithey = final.callPackage ../../packages/mywm-smithey.nix { src = inputs.mywm-smithey; };
      claude-desktop = final.callPackage ../../packages/claude-desktop.nix { };
      chatgpt-linux = final.callPackage ../../packages/chatgpt-linux.nix { };
      helium = final.callPackage ../../packages/helium.nix { };
    };
  };
}
