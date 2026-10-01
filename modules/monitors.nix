{ lib, ... }:

{
  # Single source of truth for the desktop's output names. Consumed by the
  # greeter and the XWayland primary-output service (the mywm config in dotfiles/mywm names them too).
  options.monitors = lib.mkOption {
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
