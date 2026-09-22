{ ... }:

{
  flake.modules.nixos.impermanence = {
    environment.persistence."/persist" = {
      hideMounts = true;

      directories = [
        "/var/lib/bluetooth"
        "/var/lib/NetworkManager"
      ];

      files = [
        "/etc/machine-id"
      ];
    };
  };
}
