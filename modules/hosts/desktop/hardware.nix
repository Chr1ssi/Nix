{ ... }:

{
  flake.modules.nixos.desktop-hardware =
    {
      config,
      lib,
      modulesPath,
      options,
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

      # mywm's Quickshell (bar, launcher, wallpaper picker, lock screen) on NVIDIA's EGL only: glvnd would also
      # load Mesa and LLVM into every instance for a fallback this GPU never needs (measured: 5.3 MB less
      # private memory per instance, a launcher start 17 ms sooner). Programs the launcher starts inherit it.
      programs.mywm.package = options.programs.mywm.package.default.override {
        quickshell = pkgs.symlinkJoin {
          name = "quickshell-nvidia-egl";
          paths = [ pkgs.quickshell ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            for program in $out/bin/qs $out/bin/quickshell; do
              wrapProgram "$program" --set __EGL_VENDOR_LIBRARY_FILENAMES \
                ${config.hardware.nvidia.package}/share/glvnd/egl_vendor.d/10_nvidia.json
            done
          '';
        };
      };

      services.hardware.openrgb = {
        enable = true;
      };

      # Realtek USB Bluetooth (0bda:a725); the shell's command center switches it and its devices.
      # Its pairings live in /var/lib/bluetooth (kept by impermanence).
      hardware.bluetooth.enable = true;
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
