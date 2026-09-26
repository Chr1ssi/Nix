{ ... }:

{
  flake.modules.nixos.desktop-hardware =
    {
      config,
      lib,
      modulesPath,
      pkgs,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      # Storage / USB required during early boot.
      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "sd_mod"
      ];

      # Ryzen 7 5800X3D virtualization support.
      boot.kernelModules = [
        "kvm-amd"
      ];

      # AMD CPU microcode.
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      # NVIDIA GeForce RTX 2080 Ti (Turing).
      services.xserver.videoDrivers = [
        "nvidia"
      ];

      hardware.nvidia = {
        modesetting.enable = true;
        open = true;

        package = config.boot.kernelPackages.nvidiaPackages.stable;

        nvidiaSettings = true;
      };

      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "nvidia";
        NVD_BACKEND = "direct";
      };

      services.hardware.openrgb = {
        enable = true;
      };

      # Apply the lighting once at boot instead of keeping the SDK server
      # and tray application running for the entire session.
      systemd.services.openrgb = {
        description = lib.mkForce "Apply OpenRGB startup lighting";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = lib.mkForce "no";
          ExecStart = lib.mkForce (
            "${lib.getExe pkgs.openrgb} "
            + "--device 0 --zone 0 --size 120 --mode direct --color FF008C "
            + "--device 0 --zone 1 --size 120 --mode direct --color 00D9D2"
          );
        };
      };

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
}
