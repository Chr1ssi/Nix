{ ... }:

{
  flake.modules.nixos.desktop-hardware =
    { config, lib, modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      # Keep the text greeter on the primary display at its native resolution.
      boot.kernelParams = [
        "video=DP-3:2560x1440"
        "video=DP-1:d"
        "video=HDMI-A-1:d"
      ];

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
      hardware.cpu.amd.updateMicrocode =
        lib.mkDefault config.hardware.enableRedistributableFirmware;

      # NVIDIA GeForce RTX 2080 Ti (Turing).
      services.xserver.videoDrivers = [
        "nvidia"
      ];

      hardware.nvidia = {
        modesetting.enable = true;
        open = true;

        package =
          config.boot.kernelPackages.nvidiaPackages.stable;

        nvidiaSettings = true;
      };

      services.hardware.openrgb = {
        enable = true;
      };

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
}
