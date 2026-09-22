{ ... }:

{
  flake.modules.nixos.desktop-hardware =
    { lib, ... }:
    {
      nixpkgs.hostPlatform =
        lib.mkDefault "x86_64-linux";

      # TODO:
      # Hardware configuration from the physical desktop
      # will be added before installation.
    };
}
