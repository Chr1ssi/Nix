{ inputs, ... }:

{
  perSystem = { pkgs, ... }:
    let
      mywm = inputs.mywm.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      packages = {
        inherit mywm;
        default = mywm;
      };
    };
}
