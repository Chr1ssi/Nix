{ inputs, ... }:

{
  flake.modules.nixos.nixdatifier =
    { config, pkgs, ... }:
    let
      nixdatifier = config.programs.nixdatifier.package;
    in
    {
      imports = [ inputs.nixdatifier.nixosModules.default ];

      programs.nixdatifier = {
        enable = true;
        # The module's autostart is an /etc/xdg/autostart entry, and mywm's session never starts
        # xdg-desktop-autostart.target; the user service below starts it instead.
        autostart = false;
        # Muddyblack/nixdatifier#38: the flake update check glues the run helper's path onto
        # NIXDATIFIER_IGNORE_INPUTS='…', so bash fails with "cached: command not found".
        # --replace-fail stops the build once upstream changes that line; drop the patch then.
        package =
          inputs.nixdatifier.packages.${pkgs.stdenv.hostPlatform.system}.nixdatifier.overrideAttrs
            (old: {
              postPatch = (old.postPatch or "") + ''
                chmod -R u+w ../package
                substituteInPlace ../package/contents/ui/Engine.qml \
                  --replace-fail 'shq(root.settings.ignoredInputs || "");' 'shq(root.settings.ignoredInputs || "") + " ";'
              '';
            });
      };

      # A Home Manager unit, because a NixOS user unit pins a minimal PATH: the helpers need the
      # system's nix and the setuid pkexec from /run/wrappers, which the session PATH has.
      home-manager.sharedModules = [
        {
          systemd.user.services.nixdatifier = {
            Unit = {
              Description = "Nixdatifier tray app";
              PartOf = [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
            };
            # Waits up to ~12 s for mywm-shell's tray host (the compositor spawns Quickshell itself).
            Service = {
              ExecStart = "${nixdatifier}/bin/nixdatifier --background";
              Restart = "on-failure";
            };
            Install.WantedBy = [ "graphical-session.target" ];
          };
        }
      ];
    };
}
