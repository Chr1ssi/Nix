{ ... }:

{
  flake.modules.homeManager.calendar =
    { config, pkgs, ... }:

    let
      calendarDirectory = "${config.xdg.dataHome}/calendars/icloud";

      calendar = pkgs.writeShellApplication {
        name = "mywm-calendar";
        runtimeInputs = with pkgs; [
          coreutils
          khal
          python3
          vdirsyncer
        ];
        text = ''
          case "''${1:-app}" in
            app)
              exec khal interactive
              ;;
            events)
              exec python3 - "''${2:-today}" "''${3:-31d}" <<'PY'
          from datetime import datetime
          import json
          import os
          import subprocess
          import sys
          from pathlib import Path

          calendar_root = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share")) / "calendars/icloud"
          def khal_date(value):
              try:
                  return datetime.strptime(value, "%Y-%m-%d").strftime("%d.%m.%Y")
              except ValueError:
                  return value

          colors = {}
          if calendar_root.is_dir():
              for directory in calendar_root.iterdir():
                  try:
                      name = (directory / "displayname").read_text().strip()
                      color = (directory / "color").read_text().strip()
                  except OSError:
                      continue
                  if name and color:
                      # iCloud/vdirsyncer stores #RRGGBBAA, while Qt treats an
                      # eight-digit color as #AARRGGBB. Drop the opaque alpha
                      # channel so calendar colors remain visible in QML.
                      colors[name] = color[:7] if color.startswith("#") and len(color) == 9 else color
          result = subprocess.run(
              [
                  "khal", "list", "--json", "start", "--json", "end",
                  "--json", "title", "--json", "location", "--json", "calendar",
                  khal_date(sys.argv[1]), khal_date(sys.argv[2]),
              ],
              check=False,
              capture_output=True,
              text=True,
          )
          events = []
          for line in result.stdout.splitlines():
              try:
                  day_events = json.loads(line)
              except json.JSONDecodeError:
                  continue
              for event in day_events:
                  try:
                      start = datetime.strptime(event["start"], "%d.%m.%Y %H:%M")
                      end = datetime.strptime(event["end"], "%d.%m.%Y %H:%M")
                      all_day = False
                  except (KeyError, ValueError):
                      try:
                          start = datetime.strptime(event["start"], "%d.%m.%Y")
                          end = datetime.strptime(event["end"], "%d.%m.%Y")
                          all_day = True
                      except (KeyError, ValueError):
                          continue
                  event["startDate"] = start.strftime("%Y-%m-%d")
                  event["endDate"] = end.strftime("%Y-%m-%d")
                  event["startTime"] = "" if all_day else start.strftime("%H:%M")
                  event["endTime"] = "" if all_day else end.strftime("%H:%M")
                  event["allDay"] = all_day
                  event["color"] = colors.get(event["calendar"], "")
                  if event not in events:
                      events.append(event)
          print(json.dumps(events, ensure_ascii=False))
          PY
              ;;
            calendars)
              exec python3 - <<'PY'
          import json
          import os
          from pathlib import Path

          root = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share")) / "calendars/icloud"
          calendars = []
          if root.is_dir():
              for directory in root.iterdir():
                  try:
                      name = (directory / "displayname").read_text().strip()
                      color = (directory / "color").read_text().strip()
                  except OSError:
                      continue
                  if name:
                      qml_color = color[:7] if color.startswith("#") and len(color) == 9 else color
                      calendars.append({"name": name, "color": qml_color})
          print(json.dumps(sorted(calendars, key=lambda item: item["name"]), ensure_ascii=False))
          PY
              ;;
            create)
              calendar_name="''${2:?Kalender fehlt}"
              event_date="''${3:?Datum fehlt}"
              start_time="''${4:?Startzeit fehlt}"
              end_time="''${5:?Endzeit fehlt}"
              title="''${6:?Titel fehlt}"
              location="''${7:-}"
              event_date=$(date --date="$event_date" +%d.%m.%Y)
              khal new --calendar "$calendar_name" --location "$location" \
                "$event_date $start_time" "$event_date $end_time" "$title"
              if [ -z "''${MYWM_CALENDAR_SKIP_SYNC:-}" ]; then
                vdirsyncer sync calendar_icloud
              fi
              ;;
            sync)
              exec vdirsyncer sync calendar_icloud
              ;;
            *)
              echo "Verwendung: mywm-calendar [app|events [START] [ENDE]|calendars|create KALENDER DATUM START ENDE TITEL [ORT]|sync]" >&2
              exit 2
              ;;
          esac
        '';
      };

      calendarSetup = pkgs.writeShellApplication {
        name = "mywm-calendar-setup";
        runtimeInputs = with pkgs; [
          coreutils
          libsecret
          vdirsyncer
        ];
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
        libsecret
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
            collections = [
              "from a"
              "from b"
            ];
            metadata = [
              "color"
              "displayname"
            ];
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
        categories = [
          "Office"
          "Calendar"
        ];
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
        After = [
          "network-online.target"
          "gnome-keyring-daemon.service"
        ];
        Wants = [ "network-online.target" ];
      };
    };
}
