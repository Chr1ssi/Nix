{ ... }:

{
  flake.modules.nixos.impermanence =
    { ... }:
    {
      environment.persistence."/persist" = {
        hideMounts = true;

        directories = [
          # NetworkManager connections
          "/etc/NetworkManager/system-connections"

          # Bluetooth pairings
          "/var/lib/bluetooth"

          # systemd state
          "/var/lib/systemd"

          # NixOS/system state
          "/var/lib/nixos"

          # Logs
          "/var/log"
        ];

        files = [
          # Stable SSH host identity
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"

          # Stable machine identity
          "/etc/machine-id"
        ];
      };
    };
}
