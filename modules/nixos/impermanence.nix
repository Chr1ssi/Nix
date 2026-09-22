{ ... }:

{
  flake.modules.nixos.impermanence =
    { ... }:
    {
      services.journald.storage = "persistent";

      environment.persistence."/persist" = {
        hideMounts = true;

        directories = [
          "/etc/NetworkManager/system-connections"
          "/var/lib/bluetooth"
          "/var/lib/systemd"
          "/var/lib/nixos"
          "/var/log"
        ];

        files = [
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
          "/etc/machine-id"
        ];
      };
    };
}
