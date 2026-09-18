{ config, lib, ... }:
{
  options.profiles.development.enable = lib.mkEnableOption "Neovim, VS Code and development tools";
  config = lib.mkIf config.profiles.development.enable {
    nixpkgs.config.allowUnfree = true;
    # LazyVim/Mason downloads language servers built for conventional Linux.
    programs.nix-ld.enable = true;
    home-manager.users.chris.imports = [ ../home/development.nix ];
  };
}
