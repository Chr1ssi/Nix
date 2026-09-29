{ lib, ... }:

{
  # Single source of truth for the desktop's output names. Consumed by the
  # greeter, kanshi, the mywm config and the XWayland primary-output service.
  options.flake.monitors = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    readOnly = true;
    default = {
      main = "DP-3";
      top = "HDMI-A-1";
      side = "DP-1";
    };
    description = "Output names by role: main (gaming/VRR), top (ultrawide), side (rotated).";
  };
}
