{ ... }:

{
  flake.modules.nixos.desktop-storage =
    { pkgs, ... }:
    {

      boot.initrd.systemd = {
        enable = true;

        extraBin = {
          btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
          date = "${pkgs.coreutils}/bin/date";
          stat = "${pkgs.coreutils}/bin/stat";
          sort = "${pkgs.coreutils}/bin/sort";
          sed = "${pkgs.gnused}/bin/sed";
        };

        services.rollback-root = {
          description = "Rollback Btrfs root subvolume";

          wantedBy = [ "initrd.target" ];

          requires = [
            "dev-disk-by\\x2did-nvme\\x2dLexar_SSD_NM710_1TB_NDC692R002317P2200\\x2dpart6.device"
          ];

          after = [
            "dev-disk-by\\x2did-nvme\\x2dLexar_SSD_NM710_1TB_NDC692R002317P2200\\x2dpart6.device"
          ];

          before = [
            "sysroot.mount"
          ];

          unitConfig.DefaultDependencies = false;

          serviceConfig.Type = "oneshot";

          script = ''
            mkdir -p /btrfs_tmp

            mount -t btrfs -o subvolid=5 \
              /dev/disk/by-id/nvme-Lexar_SSD_NM710_1TB_NDC692R002317P2200-part6 \
              /btrfs_tmp

            if [ -e /btrfs_tmp/@root ]; then
              mkdir -p /btrfs_tmp/@old_roots

              timestamp="$(
                date \
                  --date="@$(stat -c %Y /btrfs_tmp/@root)" \
                  "+%Y-%m-%d_%H:%M:%S"
              )"

              mv /btrfs_tmp/@root \
                "/btrfs_tmp/@old_roots/$timestamp"
            fi

            now="$(date +%s)"

            for old_root in /btrfs_tmp/@old_roots/*; do
              [ -e "$old_root" ] || continue

              root_name="''${old_root##*/}"

              root_time="$(
                date \
                  --date="''${root_name/_/ }" \
                  +%s 2>/dev/null
              )" || continue

              age="$((now - root_time))"

              if [ "$age" -ge 86400 ]; then
                echo "Deleting old root: $old_root"

                btrfs subvolume list -o "$old_root" |
                  sed -n 's/.* path //p' |
                  sort -r |
                  while read -r subvolume; do
                    btrfs subvolume delete "/btrfs_tmp/$subvolume"
                  done

                btrfs subvolume delete "$old_root"
              fi
            done

            btrfs subvolume create /btrfs_tmp/@root

            umount /btrfs_tmp
          '';
        };
      };

      fileSystems."/" = {
        device = "/dev/disk/by-label/NIXROOT";
        fsType = "btrfs";
        options = [
          "subvol=@root"
          "compress=zstd:3"
          "noatime"
          "discard=async"
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
        device =
          "/dev/disk/by-uuid/a40769b6-2e4b-4b95-b1f9-6c7a5242f686";

        fsType = "btrfs";

        options = [
          "subvol=@persist"
          "compress=zstd:3"
          "noatime"
          "discard=async"
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
        device = "/dev/disk/by-uuid/7109-AA6D";
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
    };
}
