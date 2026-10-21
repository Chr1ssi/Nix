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
      boot.kernelPackages = pkgs.linuxPackages_latest;

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

      # Early KMS: the driver (and its GSP firmware) in the initrd, so Plymouth has the GPU at once. Plymouth
      # ignores the firmware framebuffer (simpledrm) and would otherwise wait until the session starts.
      boot.initrd.kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_drm"
      ];

      hardware.nvidia = {
        modesetting.enable = true;
        open = true;

        package = config.boot.kernelPackages.nvidiaPackages.latest;

        nvidiaSettings = true;
      };

      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "nvidia";
        NVD_BACKEND = "direct";
      };

      # Video decoding on the GPU in LibreWolf. Firefox blocklists NVIDIA for it, and nvidia-vaapi-driver only
      # works outside the media (RDD) process sandbox (tested: GPU decoding needs both). The sandbox stays on
      # for everything else.
      home-manager.users.chris.programs.librewolf = {
        package = pkgs.librewolf.overrideAttrs (old: {
          makeWrapperArgs = old.makeWrapperArgs ++ [
            "--set"
            "MOZ_DISABLE_RDD_SANDBOX"
            "1"
          ];
        });
        profiles.default.settings."media.hardware-video-decoding.force-enabled" = true;
      };

      services.hardware.openrgb = {
        enable = true;
      };

      # Realtek USB Bluetooth (0bda:a725); the shell's command center switches it and its devices.
      # Its pairings live in /var/lib/bluetooth (kept by impermanence).
      hardware.bluetooth = {
        enable = true;
        # The adapter stays off at boot until it is switched on.
        powerOnBoot = false;
      };
      # It stops answering once USB autosuspend sends it to sleep (tx timeouts, then a reset as hci1, hci2, …).
      boot.extraModprobeConfig = "options btusb enable_autosuspend=0";

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
    };
}
