{ ... }:

{
  flake.modules.nixos.virtualisation =
    { pkgs, ... }:
    {
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          # Software TPM 2.0, required by Windows 11 guests.
          swtpm.enable = true;
          # Share host directories with guests via virtiofs.
          vhostUserPackages = [ pkgs.virtiofsd ];
        };
      };

      # Pass USB devices into guests through the SPICE viewer.
      virtualisation.spiceUSBRedirection.enable = true;

      programs.virt-manager.enable = true;

      users.users.chris.extraGroups = [ "libvirtd" ];

      # Root is rolled back on boot; keep VM definitions, disk images and networks.
      environment.persistence."/persist".directories = [ "/var/lib/libvirt" ];

      # Disable Btrfs copy-on-write for new disk images to avoid fragmentation.
      systemd.tmpfiles.rules = [ "h /var/lib/libvirt/images - - - - +C" ];

      environment.systemPackages = with pkgs; [
        # Windows guest drivers (virtio disk/net, QXL, guest agent) as ISO.
        virtio-win
      ];
    };
}
