{ ... }:

{
  flake.modules.nixos.vm-disko = { pkgs, ... }:
  {
    fileSystems."/persist".neededForBoot = true;

    boot.initrd.systemd = {
      enable = true;

      extraBin = {
        btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
      };

      services.rollback-root = {
        description = "Rollback Btrfs root subvolume";

        wantedBy = [ "initrd.target" ];

        requires = [
          "dev-vda2.device"
        ];

        after = [
          "dev-vda2.device"
        ];

        before = [
          "sysroot.mount"
        ];

        unitConfig.DefaultDependencies = false;

        serviceConfig.Type = "oneshot";

        script = ''
          mkdir -p /btrfs_tmp

          mount -t btrfs -o subvolid=5 /dev/vda2 /btrfs_tmp

          if [ -e /btrfs_tmp/@root ]; then
            mkdir -p /btrfs_tmp/@old_roots

            timestamp="$(date --date="@$(stat -c %Y /btrfs_tmp/@root)" "+%Y-%m-%d_%H:%M:%S")"

            mv /btrfs_tmp/@root \
              "/btrfs_tmp/@old_roots/$timestamp"
          fi

          btrfs subvolume create /btrfs_tmp/@root

          umount /btrfs_tmp
        '';
      };
    };

    disko.devices = {
      disk.main = {
        type = "disk";

        # QEMU VM
        device = "/dev/vda";

        content = {
          type = "gpt";

          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";

              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";

                mountOptions = [
                  "umask=0077"
                ];
              };
            };

            root = {
              size = "100%";

              content = {
                type = "btrfs";

                extraArgs = [
                  "-f"
                ];

                subvolumes = {
                  "@root" = {
                    mountpoint = "/";

                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };

                  "@nix" = {
                    mountpoint = "/nix";

                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };

                  "@persist" = {
                    mountpoint = "/persist";

                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };

                  "@home" = {
                    mountpoint = "/home";

                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };

                  "@swap" = {
                    mountpoint = "/swap";

                    swap.swapfile.size = "8G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
