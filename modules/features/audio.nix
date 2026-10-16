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

        # Noise suppression, then a voice EQ (tuned for the Wave:3), on whichever microphone is the default: a
        # WirePlumber smart filter sits between the default source and every application recording from "default".
        # This used to be EasyEffects' input preset; PipeWire runs the same chain without a GUI process, and only
        # while something records.
        extraConfig.pipewire."90-mic-filter"."context.modules" = [
          {
            name = "libpipewire-module-filter-chain";
            args = {
              "node.description" = "Mic Filter";
              "media.name" = "Mic Filter";
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
                "node.name" = "capture.mic_filter";
                # Wait unlinked while there is no microphone yet. Without it WirePlumber destroys the stream when
                # PipeWire starts before the ALSA nodes exist (at login), and the whole filter is gone until a restart.
                "node.linger" = true;
                # The microphone and the filters only run while an application records.
                "node.passive" = true;
              };
              "playback.props" = {
                "node.name" = "mic_filter";
                "media.class" = "Audio/Source";
                # No filter.smart.target: the filter follows the default source and moves along when it changes.
                # It never becomes the default itself.
                "filter.smart" = true;
                "filter.smart.name" = "mic-filter";
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
