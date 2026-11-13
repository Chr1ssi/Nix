{ ... }:

{
  flake.modules.homeManager.calendar =
    { config, pkgs, ... }:

    let
      calendarDirectory = "${config.xdg.dataHome}/calendars/icloud";
      # iCloud has no birthday calendar on the server: the iPhone makes its own from the contacts.
      # `splice-calendar birthdays` does the same from the synced address book, into a local calendar
      # of its own. (khal's `birthdays` calendars cannot: its parser rejects iCloud's `BDAY;VALUE=date:`.)
      contactsDirectory = "${config.xdg.dataHome}/contacts/icloud";
      birthdaysDirectory = "${config.xdg.dataHome}/calendars/geburtstage";
      secretLookup = kind: [
        "${pkgs.libsecret}/bin/secret-tool"
        "lookup"
        "service"
        "mywm-calendar"
        "kind"
        kind
      ];
      # The keyring entries keep `service mywm-calendar` (the old project name): they are what the stored
      # credentials are found by, so renaming them would hide those.

      calendar = pkgs.writeShellApplication {
        name = "splice-calendar";
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
            birthdays)
              exec python3 - ${contactsDirectory} ${birthdaysDirectory} <<'PY'
          import re
          import sys
          from datetime import date, timedelta
          from pathlib import Path

          contacts, target = Path(sys.argv[1]), Path(sys.argv[2])
          target.mkdir(parents=True, exist_ok=True)
          wanted = {}
          for card in contacts.glob("*/*.vcf"):
              fields = {}
              # A line that starts with a space continues the one before.
              for line in re.sub(r"\r?\n[ \t]", "", card.read_text(errors="replace")).splitlines():
                  key, _, value = line.partition(":")
                  # `item1.BDAY;VALUE=date` is `BDAY`.
                  fields.setdefault(key.split(";")[0].split(".")[-1].upper(), value.strip())
              # 1985-04-12, 19850412 or, without a year, --04-12; Apple writes 1604 for "no year".
              match = re.fullmatch(r"(\d{4}|--)-?(\d{2})-?(\d{2})(T.*)?", fields.get("BDAY", ""))
              # Some cards have an empty FN; N is "family;given;…".
              family, given = (fields.get("N", "").split(";") + [""])[:2]
              name = fields.get("FN") or " ".join(part for part in (given, family) if part)
              if not match or not name:
                  continue
              year = 0 if match[1] in ("--", "1604") else int(match[1])
              try:
                  # Without a year the series starts in a leap year, so that 29 February exists.
                  start = date(year or 1904, int(match[2]), int(match[3]))
              except ValueError:
                  continue
              uid = re.sub(r"[^A-Za-z0-9-]", "-", fields.get("UID") or card.stem)
              lines = [
                  "BEGIN:VCALENDAR",
                  "VERSION:2.0",
                  "PRODID:-//splice-calendar//birthdays//DE",
                  "BEGIN:VEVENT",
                  f"UID:birthday-{uid}",
                  "DTSTAMP:19700101T000000Z",
                  f"DTSTART;VALUE=DATE:{start:%Y%m%d}",
                  f"DTEND;VALUE=DATE:{start + timedelta(days=1):%Y%m%d}",
                  "RRULE:FREQ=YEARLY",
                  # vCard and iCalendar escape text the same way: the name goes over as it is.
                  f"SUMMARY:Geburtstag von {name}",
                  *([f"DESCRIPTION:Jahrgang {year}"] if year else []),
                  "TRANSP:TRANSPARENT",
                  "END:VEVENT",
                  "END:VCALENDAR",
              ]
              wanted[f"birthday-{uid}.ics"] = "\r\n".join(lines) + "\r\n"
          # Only what changed is written: khal reads the calendar again when its files change.
          for file in target.glob("*.ics"):
              if file.name not in wanted:
                  file.unlink()
          for name, text in wanted.items():
              file = target / name
              if not file.exists() or file.read_text(newline="") != text:
                  file.write_text(text, newline="")
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
              if [ -z "''${SPLICE_CALENDAR_SKIP_SYNC:-}" ]; then
                vdirsyncer sync calendar_icloud
              fi
              ;;
            sync)
              exec vdirsyncer sync calendar_icloud
              ;;
            *)
              echo "Verwendung: splice-calendar [app|events [START] [ENDE]|calendars|birthdays|create KALENDER DATUM START ENDE TITEL [ORT]|sync]" >&2
              exit 2
              ;;
          esac
        '';
      };

      calendarSetup = pkgs.writeShellApplication {
        name = "splice-calendar-setup";
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
            --label='splice iCloud-Kalender Apple-ID' service mywm-calendar kind username
          printf '%s' "$app_password" | secret-tool store \
            --label='splice iCloud-Kalender Passwort' service mywm-calendar kind password
          unset app_password

          vdirsyncer discover calendar_icloud
          vdirsyncer sync calendar_icloud
          # The address book's folder does not exist yet: let vdirsyncer create it.
          vdirsyncer discover contacts_icloud <<<y
          vdirsyncer sync contacts_icloud
          ${calendar}/bin/splice-calendar birthdays
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
            passwordCommand = secretLookup "password";
          };
          khal = {
            enable = true;
            type = "discover";
          };
          vdirsyncer = {
            enable = true;
            userNameCommand = secretLookup "username";
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

      accounts.contact = {
        basePath = "${config.xdg.dataHome}/contacts";
        accounts.icloud = {
          local = {
            path = contactsDirectory;
            type = "filesystem";
            fileExt = ".vcf";
          };
          remote = {
            type = "carddav";
            url = "https://contacts.icloud.com/";
            passwordCommand = secretLookup "password";
          };
          vdirsyncer = {
            enable = true;
            userNameCommand = secretLookup "username";
            collections = [
              "from a"
              "from b"
            ];
            conflictResolution = "remote wins";
          };
        };
      };

      # Made from the contacts after every sync; khal only reads it.
      accounts.calendar.accounts.Geburtstage = {
        local = {
          path = birthdaysDirectory;
          type = "filesystem";
          fileExt = ".ics";
        };
        khal = {
          enable = true;
          readOnly = true;
        };
      };

      xdg.desktopEntries.splice-calendar = {
        name = "Kalender";
        comment = "iCloud-Kalender mit khal";
        icon = "x-office-calendar";
        terminal = false;
        exec = "${pkgs.foot}/bin/foot --app-id splice-calendar --title Kalender ${calendar}/bin/splice-calendar app";
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

      systemd.user.services.vdirsyncer.Service.ExecStartPost =
        "${calendar}/bin/splice-calendar birthdays";

      systemd.user.services.vdirsyncer.Unit = {
        After = [
          "network-online.target"
          "gnome-keyring-daemon.service"
        ];
        Wants = [ "network-online.target" ];
      };
    };
}
