{ ... }:

{
  # Hand-packaged apps (see ../../packages), reachable as pkgs.local.<name>.
  flake.overlays.local = final: prev: {
    # nixpkgs' khal sets sphinxBuilders as a list; with structuredAttrs that
    # becomes a bash array and sphinx-hook only sees "html", so the declared
    # "man" output is never produced. A plain string survives as one word list.
    khal = prev.khal.overrideAttrs { sphinxBuilders = "html man"; };

    local = {
      claude-desktop = final.callPackage ../../packages/claude-desktop.nix { };
      slot-nord-dark-colorize-icons =
        final.callPackage ../../packages/slot-nord-dark-colorize-icons.nix
          { };
    };
  };
}
