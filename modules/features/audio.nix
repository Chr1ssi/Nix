{ config, ... }:

{
  flake.modules.nixos.audio =
    { pkgs, ... }:
    let
      biquad = name: label: control: {
        type = "builtin";
        inherit name label control;
      };
    in
    {
      home-manager.sharedModules = [ config.flake.modules.homeManager.audio ];

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;

        # The Wave:3 as the source "Wave:3 Clean": noise suppression, then a voice EQ. This used to be EasyEffects'
        # input preset; PipeWire runs the same chain without a GUI process, and only while something records.
        extraConfig.pipewire."90-wave3-clean"."context.modules" = [
          {
            name = "libpipewire-module-filter-chain";
            args = {
              "node.description" = "Wave:3 Clean";
              "media.name" = "Wave:3 Clean";
              # The graph is mono; PipeWire runs one copy per channel.
              "audio.channels" = 2;
              "audio.position" = [
                "FL"
                "FR"
              ];
              "filter.graph" = {
                nodes = [
                  {
                    type = "ladspa";
                    name = "rnnoise";
                    plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                    label = "noise_suppressor_mono";
                    # Threshold 0 = no voice gate, only the denoising (EasyEffects had its VAD off).
                    control."VAD Threshold (%)" = 0;
                  }
                  # -1 dB in front of the EQ.
                  (biquad "trim" "linear" { Mult = 0.891; })
                  # Two sections for the 24 dB/oct high-pass (EasyEffects' slope x2).
                  (biquad "rumble1" "bq_highpass" {
                    Freq = 70.0;
                    Q = 0.7;
                  })
                  (biquad "rumble2" "bq_highpass" {
                    Freq = 70.0;
                    Q = 0.7;
                  })
                  (biquad "body" "bq_lowshelf" {
                    Freq = 120.0;
                    Q = 0.7;
                    Gain = 2.0;
                  })
                  (biquad "mud" "bq_peaking" {
                    Freq = 280.0;
                    Q = 1.0;
                    Gain = -1.5;
                  })
                  (biquad "presence" "bq_peaking" {
                    Freq = 3500.0;
                    Q = 0.9;
                    Gain = 1.5;
                  })
                  (biquad "air" "bq_highshelf" {
                    Freq = 9000.0;
                    Q = 0.7;
                    Gain = 0.5;
                  })
                ];
                links = [
                  {
                    output = "rnnoise:Output";
                    input = "trim:In";
                  }
                  {
                    output = "trim:Out";
                    input = "rumble1:In";
                  }
                  {
                    output = "rumble1:Out";
                    input = "rumble2:In";
                  }
                  {
                    output = "rumble2:Out";
                    input = "body:In";
                  }
                  {
                    output = "body:Out";
                    input = "mud:In";
                  }
                  {
                    output = "mud:Out";
                    input = "presence:In";
                  }
                  {
                    output = "presence:Out";
                    input = "air:In";
                  }
                ];
              };
              "capture.props" = {
                "node.name" = "capture.wave3_clean";
                "target.object" = "alsa_input.usb-Elgato_Elgato_Wave_3_MK.2_AD0JH55010ALJB-00.analog-stereo";
                # Never the default source instead (no Wave:3, e.g. in the VM).
                "node.dont-fallback" = true;
                # Wait unlinked until the Wave:3 is there. Without it WirePlumber destroys the stream when PipeWire
                # starts before the ALSA nodes exist (at login), and the whole filter is gone until a restart.
                "node.linger" = true;
                # The microphone and the filters only run while an application records from "Wave:3 Clean".
                "node.passive" = true;
              };
              "playback.props" = {
                "node.name" = "wave3_clean";
                "media.class" = "Audio/Source";
                # Above the hardware sources (the Wave:3 has 2109), so it is the default microphone.
                "priority.session" = 2500;
              };
            };
          }
        ];
      };
    };

  flake.modules.homeManager.audio =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        pavucontrol
        playerctl
      ];
    };
}
