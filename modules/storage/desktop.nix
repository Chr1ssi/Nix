{ ... }:

{
  flake.modules.nixos.desktop-storage =
    { ... }:
    {
      fileSystems."/" = {
        device = "/dev/disk/by-label/NIXROOT";
        fsType = "btrfs";
        options = [
          "subvol=@root"
          "compress=zstd"
          "noatime"
        ];
      };

      fileSystems."/nix" = {
        device = "/dev/disk/by-label/NIXROOT";
        fsType = "btrfs";
        options = [
          "subvol=@nix"
          "compress=zstd"
          "noatime"
        ];
      };

      fileSystems."/persist" = {
        device = "/dev/disk/by-label/NIXROOT";
        fsType = "btrfs";
        options = [
          "subvol=@persist"
          "compress=zstd"
          "noatime"
        ];

        neededForBoot = true;
      };

      fileSystems."/home" = {
        device = "/dev/disk/by-label/NIXROOT";
        fsType = "btrfs";
        options = [
          "subvol=@home"
          "compress=zstd"
          "noatime"
        ];
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-label/NIXBOOT";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      fileSystems."/mnt/bigdata" = {
        device =
          "/dev/disk/by-uuid/4916da84-017d-4355-acdb-af132e025038";

        fsType = "ext4";
        options = [ "nofail" ];
      };

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
      };

      boot.initrd.systemd.enable = true;

      boot.initrd.systemd.services.rollback = {
        description = "Rollback Btrfs root subvolume";
        wantedBy = [ "initrd.target" ];
        before = [ "sysroot.mount" ];

        unitConfig.DefaultDependencies = "no";

        serviceConfig.Type = "oneshot";

        script = ''
          mkdir -p /mnt

          mount -t btrfs -o subvolid=5 \
            /dev/disk/by-label/NIXROOT /mnt

          btrfs subvolume delete /mnt/@root
          btrfs subvolume create /mnt/@root

          umount /mnt
        '';
      };

    };
}
