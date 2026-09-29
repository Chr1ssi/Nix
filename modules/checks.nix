{ config, lib, ... }:

{
  systems = [ "x86_64-linux" ];

  perSystem =
    { pkgs, ... }:
    let
      src = lib.fileset.toSource {
        root = ../.;
        fileset = lib.fileset.fileFilter (file: file.hasExt "nix") ../.;
      };
    in
    {
      formatter = pkgs.nixfmt;

      checks = {
        formatting =
          pkgs.runCommand "nixfmt-check"
            {
              nativeBuildInputs = [
                pkgs.nixfmt
                pkgs.findutils
              ];
            }
            ''
              find ${src} -name "*.nix" -print0 | xargs -0 nixfmt --check
              touch $out
            '';

        deadnix = pkgs.runCommand "deadnix-check" { nativeBuildInputs = [ pkgs.deadnix ]; } ''
          deadnix --fail ${src}
          touch $out
        '';

        # Gate: both NixOS hosts must still build.
        desktop = config.flake.nixosConfigurations.desktop.config.system.build.toplevel;
        vm = config.flake.nixosConfigurations.vm.config.system.build.toplevel;
      };
    };
}
