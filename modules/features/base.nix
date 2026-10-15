{ config, ... }:

{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [ config.flake.overlays.local ];

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };

      nix.optimise.automatic = true;

      # Builds get only the CPU and disk time nothing else wants, so the desktop stays responsive during a rebuild.
      nix.daemonCPUSchedPolicy = "idle";
      nix.daemonIOSchedClass = "idle";

      networking.networkmanager.enable = true;

      services.openssh = {
        enable = true;
        openFirewall = true;
        # Started by the socket on the first connection instead of running all the time.
        startWhenNeeded = true;
      };

      time.timeZone = "Europe/Berlin";

      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings = builtins.listToAttrs (
        map
          (name: {
            inherit name;
            value = "de_DE.UTF-8";
          })
          [
            "LC_ADDRESS"
            "LC_IDENTIFICATION"
            "LC_MEASUREMENT"
            "LC_MONETARY"
            "LC_NAME"
            "LC_NUMERIC"
            "LC_PAPER"
            "LC_TELEPHONE"
            "LC_TIME"
          ]
      );

      console.keyMap = "de";
      services.xserver.xkb.layout = "de";

      environment.systemPackages = with pkgs; [
        curl
        wget
        unzip
      ];
    };
}
