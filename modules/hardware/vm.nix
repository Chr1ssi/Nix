{ ... }:

{
  flake.modules.nixos.vm-hardware =
    { modulesPath, lib, ... }:
    {
      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
      ];

      boot.initrd.availableKernelModules = [
        "ahci"
        "xhci_pci"
        "virtio_pci"
        "sr_mod"
        "virtio_blk"
      ];

      boot.kernelModules = [
        "kvm-amd"
      ];

      nixpkgs.hostPlatform =
        lib.mkDefault "x86_64-linux";
    };
}
