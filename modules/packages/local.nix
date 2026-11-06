{ ... }:

{
  # Hand-packaged apps (see ../../packages), reachable as pkgs.local.<name>.
  flake.overlays.local = final: prev: {
    # nixpkgs' khal sets sphinxBuilders as a list; with structuredAttrs that
    # becomes a bash array and sphinx-hook only sees "html", so the declared
    # "man" output is never produced. A plain string survives as one word list.
    khal = prev.khal.overrideAttrs { sphinxBuilders = "html man"; };

    # nixpkgs' pinned node_modules hash no longer matches what `bun install`
    # fetches (stale at 2.2.5). opencode-desktop inherits node_modules from
    # opencode, so overriding it here fixes both. Drop once nixpkgs updates it.
    opencode = prev.opencode.overrideAttrs (old: {
      node_modules = old.node_modules.overrideAttrs {
        outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
      };
    });

    local = {
      claude-desktop = final.callPackage ../../packages/claude-desktop.nix { };
      slot-nord-dark-colorize-icons =
        final.callPackage ../../packages/slot-nord-dark-colorize-icons.nix
          { };
    };
  };
}
