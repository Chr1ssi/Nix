{ config, ... }:

{
  flake.modules.nixos.audio = {
    home-manager.sharedModules = [ config.flake.modules.homeManager.audio ];

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  flake.modules.homeManager.audio =
    { pkgs, ... }:

    let
      loadEasyEffectsPreset = pkgs.writeShellApplication {
        name = "load-easyeffects-preset";
        runtimeInputs = with pkgs; [
          coreutils
          easyeffects
        ];
        text = ''
          for _ in {1..100}; do
            if [[ -S "''${XDG_RUNTIME_DIR}/EasyEffectsServer" ]]; then
              break
            fi
            sleep 0.1
          done

          if [[ ! -S "''${XDG_RUNTIME_DIR}/EasyEffectsServer" ]]; then
            echo "Easy Effects IPC socket did not become ready; leaving audio service running" >&2
            exit 0
          fi

          for attempt in {1..3}; do
            if timeout 10s easyeffects --load-preset "Wave3 Clean"; then
              exit 0
            fi
            echo "Could not load Easy Effects preset (attempt $attempt/3)" >&2
            sleep 1
          done

          echo "Giving up loading the Easy Effects preset; leaving audio service running" >&2
        '';
      };
    in
    {
      xdg.dataFile."easyeffects/input/Wave3 Clean.json".source =
        ../../dotfiles/easyeffects/input/Wave3-Clean.json;

      home.packages = with pkgs; [
        easyeffects
        pavucontrol
        playerctl
      ];

      systemd.user.services = {
        easyeffects = {
          Unit = {
            Description = "Easy Effects audio processing";
            PartOf = [ "graphical-session.target" ];
            After = [
              "graphical-session.target"
              "pipewire.service"
            ];
          };
          Service = {
            ExecStart = "${pkgs.easyeffects}/bin/easyeffects --service-mode --hide-window";
            ExecStartPost = "${loadEasyEffectsPreset}/bin/load-easyeffects-preset";
            Restart = "on-failure";
            RestartSec = 2;
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
    };
}
