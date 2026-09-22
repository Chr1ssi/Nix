{ ... }:

{
  flake.modules.nixos.desktop-disko = {
    # Intentionally empty for now.
    #
    # Before installing the physical desktop we will add:
    #
    # disko.devices.disk.main.device =
    #   "/dev/disk/by-id/...";
    #
    # together with the final partition layout.
  };
}
