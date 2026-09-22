{ inputs, ... }:

{
  perSystem = { pkgs, system, ... }:
    let
      mywm = pkgs.callPackage ../../packages/mywm.nix {
        src = inputs.mywm-src;
        shellSrc = inputs.mywm-shell-src;
      };
    in
    {
      packages = {
        inherit mywm;
        default = mywm;
      };

      _module.args.mywm = mywm;
    };
}
