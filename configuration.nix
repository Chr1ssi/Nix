{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./modules/nixos/base.nix
    ./modules/nixos/desktop.nix
    ./modules/nixos/gaming.nix
    ./modules/nixos/development.nix
  ];
  # Optional profiles; the initial installation contains only essentials.
  profiles.gaming.enable = false;
  profiles.development.enable = false;

  networking.hostName = "nixos";
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
    useOSProber = true;
    fsIdentifier = "provided";
  };
  users.users.chris = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };
  # Preserve compatibility with the original installation.
  system.stateVersion = "26.05";
}
