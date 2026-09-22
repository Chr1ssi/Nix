{ ... }:

{
  flake.modules.nixos.development = {
    nixpkgs.config.allowUnfree = true;

    # LazyVim/Mason downloads conventional Linux binaries.
    programs.nix-ld.enable = true;
  };
}
