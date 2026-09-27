{ ... }:

{
  flake.modules.homeManager.calendar =
    { config, pkgs, ... }:

    let
      calendarDirectory = "${config.xdg.dataHome}/calendars/icloud";

      calendar = pkgs.writeShellApplication {
        name = "mywm-calendar";
        runtimeInputs = with pkgs; [ khal python3 vdirsyncer ];
        text = ''
          case "''${1:-app}" in
            app)
              exec khal interactive
              ;;
            events)
              exec python3 - "''${2:-31d}" <<'PY'
          import json
          import os
          import subprocess
          import sys
          from pathlib import Path

          separator = "\x1f"
          calendar_root = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share")) / "calendars/icloud"
          colors = {}
          if calendar_root.is_dir():
              for directory in calendar_root.iterdir():
                  try:
                      name = (directory / "displayname").read_text().strip()
                      color = (directory / "color").read_text().strip()
                  except OSError:
                      continue
                  if name and color:
                      colors[name] = color
          result = subprocess.run(
              [
                  "khal", "list", "--day-format", "", "--format",
                  separator.join(("{start-long}", "{end-long}", "{title}", "{location}", "{calendar}")),
                  "today", sys.argv[1],
              ],
              check=False,
              capture_output=True,
              text=True,
          )
          events = []
          for line in result.stdout.splitlines():
              fields = line.split(separator)
              if len(fields) != 5:
                  continue
              event = dict(zip(("start", "end", "title", "location", "calendar"), fields))
              event["color"] = colors.get(event["calendar"], "")
              events.append(event)
          print(json.dumps(events, ensure_ascii=False))
          PY
              ;;
            sync)
              exec vdirsyncer sync calendar_icloud
              ;;
            *)
              echo "Verwendung: mywm-calendar [app|events [ZEITRAUM]|sync]" >&2
              exit 2
              ;;
          esac
        '';
      };

      calendarSetup = pkgs.writeShellApplication {
        name = "mywm-calendar-setup";
        runtimeInputs = with pkgs; [ coreutils libsecret vdirsyncer ];
        text = ''
          printf 'Apple-ID: '
          IFS= read -r apple_id
          if [ -z "$apple_id" ]; then
            echo 'Die Apple-ID darf nicht leer sein.' >&2
            exit 1
          fi

          printf 'App-spezifisches Passwort: '
          IFS= read -rs app_password
          printf '\n'
          if [ -z "$app_password" ]; then
            echo 'Das app-spezifische Passwort darf nicht leer sein.' >&2
            exit 1
          fi

          printf '%s' "$apple_id" | secret-tool store \
            --label='mywm iCloud-Kalender Apple-ID' service mywm-calendar kind username
          printf '%s' "$app_password" | secret-tool store \
            --label='mywm iCloud-Kalender Passwort' service mywm-calendar kind password
          unset app_password

          vdirsyncer discover calendar_icloud
          vdirsyncer sync calendar_icloud
          systemctl --user start vdirsyncer.service
          echo 'Der iCloud-Kalender ist eingerichtet.'
        '';
      };
    in
    {
      home.packages = with pkgs; [
        calendar
        calendarSetup
        khal
        libsecret
        vdirsyncer
      ];

      programs.khal = {
        enable = true;
        locale = {
          dateformat = "%d.%m.%Y";
          longdateformat = "%A %d. %B %Y";
          timeformat = "%H:%M";
          datetimeformat = "%d.%m.%Y %H:%M";
          longdatetimeformat = "%A %d. %B %Y %H:%M";
          firstweekday = 0;
          weeknumbers = "left";
        };
        settings = {
          default.timedelta = "7d";
          view.agenda_event_format = "{start-end-time-style} {title} {location}";
        };
      };

      programs.vdirsyncer.enable = true;
      services.vdirsyncer = {
        enable = true;
        frequency = "*:0/5";
      };

      accounts.calendar = {
        basePath = "${config.xdg.dataHome}/calendars";
        accounts.icloud = {
          primary = true;
          primaryCollection = "Privat";
          local = {
            path = calendarDirectory;
            type = "filesystem";
            fileExt = ".ics";
          };
          remote = {
            type = "caldav";
            url = "https://caldav.icloud.com/";
            passwordCommand = [
              "${pkgs.libsecret}/bin/secret-tool"
              "lookup"
              "service"
              "mywm-calendar"
              "kind"
              "password"
            ];
          };
          khal = {
            enable = true;
            type = "discover";
          };
          vdirsyncer = {
            enable = true;
            userNameCommand = [
              "${pkgs.libsecret}/bin/secret-tool"
              "lookup"
              "service"
              "mywm-calendar"
              "kind"
              "username"
            ];
            collections = [ "from a" "from b" ];
            metadata = [ "color" "displayname" ];
            conflictResolution = "remote wins";
          };
        };
      };

      xdg.desktopEntries.mywm-calendar = {
        name = "Kalender";
        comment = "iCloud-Kalender mit khal";
        icon = "x-office-calendar";
        terminal = false;
        exec = "${pkgs.kitty}/bin/kitty --class mywm-calendar --title Kalender ${calendar}/bin/mywm-calendar app";
        categories = [ "Office" "Calendar" ];
        mimeType = [ "text/calendar" ];
      };

      # khal ships its own terminal-only launcher. Keep the tailored entry
      # above as the single visible calendar application.
      xdg.desktopEntries.khal = {
        name = "ikhal";
        exec = "ikhal";
        terminal = true;
        noDisplay = true;
      };

      systemd.user.services.vdirsyncer.Unit = {
        After = [ "network-online.target" "gnome-keyring-daemon.service" ];
        Wants = [ "network-online.target" ];
      };
    };
}
