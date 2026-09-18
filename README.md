# NixOS mit mywm und Quickshell

Die Konfiguration ist für die vorhandene x86_64-NixOS-VM (`nixos`, Benutzer
`chris`) eingerichtet. Hardware, GRUB-Laufwerk `/dev/vda` und beide
`stateVersion`-Werte bleiben erhalten. Nicht unverändert auf echter Hardware
installieren: Dafür zunächst deren Hardware-Konfiguration erzeugen.

## Module

- `configuration.nix`: VM-Einstellungen und Profil-Schalter.
- `modules/nixos/base.nix`: Netzwerk, SSH, Sprache, Zeitzone und Nix.
- `modules/nixos/desktop.nix`: River/mywm-Sitzung über greetd, Audio, Portale,
  Schlüsselbund und Sperrbildschirm-PAM.
- `modules/home/essentials.nix`: Firefox, Kitty, Nautilus, mpv, imv,
  Netzwerk-/Audiowerkzeuge, Zwischenablage, Dunst und GTK-Erscheinungsbild.
- `modules/home/mywm.nix`: WM-Konfiguration als Nix-Attributsatz, den
  `pkgs.formats.toml` nach TOML übersetzt; außerdem Kanshi und Wallpaper.
- `modules/nixos/gaming.nix`: Steam samt 32-Bit-Unterstützung, Heroic und Vesktop.
- `modules/nixos/development.nix` und `modules/home/development.nix`: Neovim mit
  deiner LazyVim-Konfiguration, VS Code, Git-Editor, Rust, Python, Node.js und
  Build-/Suchwerkzeuge. Weitere projektspezifische SDKs gehören in Devshells.
- `packages/mywm.nix`: Rust-Build mit Cargo.lock und Quickshell-Dateien aus GitHub.
- `modules/nixos/scripts/`: lokale NixOS-Sitzungs- und Portal-Anbindung.

Die optionalen Profile sind zunächst aus. In `configuration.nix` aktivieren:

```nix
profiles.gaming.enable = true;
profiles.development.enable = true;
```

Steam und VS Code benötigen unfreie Pakete; deren Freigabe erfolgt erst beim
Aktivieren eines dieser Profile. Home Manager wird durch den NixOS-Rebuild
mitaktiviert und braucht keinen separaten `home-manager switch`.

## GitHub-Quellen und erster Build

Die Flake bezieht den Anwendungscode direkt aus
[Chr1ssi/mywm](https://github.com/Chr1ssi/mywm) und
[Chr1ssi/mywm-shell](https://github.com/Chr1ssi/mywm-shell).
`flake.lock` fixiert beide auf konkrete Commits. Benachbarte Checkouts sind weder
für den Build noch für die laufende Sitzung erforderlich.

Alle persönlichen Einstellungen liegen in diesem `nixos`-Repository:
`modules/home/mywm.nix` konfiguriert den WM und die gemeinsame Shell-Palette,
`modules/nixos/desktop.nix` und `modules/nixos/scripts/` die Sitzung und Portale,
`dotfiles/` die Programmeinstellungen. Die QML-Komponenten selbst sind
Anwendungscode und kommen aus dem Shell-Repository.

Uncommittete oder noch nicht gepushte Änderungen in den Entwicklungs-Checkouts
werden nicht verwendet. Das betrifft beim Wechsel unter anderem die lokalen
Quickshell-Designänderungen. Um später veröffentlichte Änderungen zu übernehmen,
nur die beiden Anwendungs-Inputs aktualisieren (nixpkgs bleibt unverändert):

```sh
cd /home/chris/Projects/nixos
nix flake update mywm-src mywm-shell-src --flake "path:$PWD"
nix build "path:$PWD#mywm"
nix build "path:$PWD#nixosConfigurations.nixos.config.system.build.toplevel"
```

`path:$PWD` berücksichtigt auch neue, noch nicht mit Git vorgemerkte Module.
Nach Aufnahme aller neuen Dateien in Git kann alternativ `.#…` verwendet werden.
Der vorhandene nixpkgs-/Home-Manager-Pin wird beibehalten. River muss mindestens
Version 0.4 sein, Quickshell verwendet die APIs der mit 0.3.1 getesteten Shell.

Nur **innerhalb der NixOS-VM** aktivieren, danach ab- und wieder anmelden:

```sh
sudo nixos-rebuild switch --flake "path:$PWD#nixos"
```

Auf CachyOS genügt Nix für Auswertung und Build; dort keinen NixOS-Rebuild ausführen.

## Sitzung und Anpassungen

Tuigreet startet `mywm-session`, dieses startet River und das lokale
`modules/nixos/scripts/river-init`. Das Skript verwaltet mywm, Kanshi, Idle, Bar und Wallpaper sowie
zusätzlich einen Polkit-Agenten. Die Sitzung setzt Store-Pfade und importiert
die Display-Umgebung für D-Bus-Portale. Xwayland bleibt über River verfügbar.
Swaylock authentifiziert über NixOS-PAM. GTK übernimmt Dateiauswahl,
xdg-desktop-portal-wlr die Bildschirmfreigabe mit Zenity-Quellenauswahl.

In der VM wird keine Zuordnung zu deinen physischen DP-/HDMI-Monitoren gesetzt.
Die neun Workspaces und Tastenkürzel kommen aus mywm; `Super+Return` startet
Kitty, `Super+Space` den Launcher, `Super+Escape` sperrt, `Super+M` meldet ab.
Monitorprofile kannst du im Home-Modul als Kanshi-Konfiguration ergänzen.
Wallpaper liegen unter `~/Pictures/Wallpapers`; das bestehende Bild wird dort
installiert, weitere Bilder können hinzugefügt werden.

Dunst übernimmt Benachrichtigungen, bis mywm-shell diese selbst implementiert.
Matugen/awww werden nicht mehr benötigt; Quickshell verwaltet das Wallpaper.

## Übernommene Dotfiles

`dotfiles/` enthält eine Kopie ausgewählter Einstellungen des CachyOS-Systems:

- Kitty einschließlich Noctalia-Palette, Transparenz und Padding.
- Neovim/LazyVim einschließlich Plugins, Sprach-Extras, QWERTZ-Tasten und Palette.
- GTK-3/4-CSS; die übernommenen GTK-3-Einstellungen stehen direkt im Home-Modul. Adw-gtk3 und Bibata-Modern-Ice werden als Nix-Pakete installiert.
- Vesktop-Oberflächeneinstellungen; Konten, Tokens und Sitzungsdaten werden nicht
  übernommen. Die deklarative Vesktop-Datei ist schreibgeschützt: Einstellungen
  dauerhaft in `dotfiles/vesktop/settings.json` ändern.

Noctalia-Farben sind statische Momentaufnahmen und benötigen keinen Noctalia-
Dienst. WM-/Shell-Farben stehen unabhängig davon im mywm-Home-Modul. Für VS Code,
mpv und imv wurde keine bestehende Konfiguration gefunden. Git hatte nur
`core.editor = fresh`; im Entwicklungsprofil wird dafür das gewünschte Neovim
verwendet.

LazyVim lädt Plugins beim ersten Start aus dem Netz. Lua-Dateien werden
schreibgeschützt durch Home Manager verwaltet, `lazyvim.json` und der Lockfile
werden einmalig aus der Kopie initialisiert und bleiben beschreibbar. Der
Plugin-Lockfile liegt unter `~/.local/state/nvim/lazy-lock.json`. Seine Updates
werden nicht automatisch ins Repository zurückgeschrieben. `nix-ld` im
Entwicklungsprofil unterstützt heruntergeladene Mason-Sprachserver; die einzelnen
Sprach-Extras können weitere SDKs verlangen und sind nicht Teil des Nix-Builds.

## Praktische Prüfung in der VM

Nach erfolgreichem Build: Login, Terminal/Launcher, Audio, Benachrichtigung,
Dateidialog, Bildschirmfreigabe, Passwort-Entsperren und Logout testen. Steam und
Spiele hängen zusätzlich von der 3D-Beschleunigung der VM ab. Nix-Auswertung oder
Build ersetzen diese Sitzungstests nicht.

## Durchgeführte Validierung (18.09.2026)

- Nix-Syntax aller Module sowie Lua-, JSON- und XML-Syntax geprüft.
- NixOS-Basissystem mit den gesperrten GitHub-Quellen vollständig gebaut, ohne
  Aktivierung auf dem Host; lokale Sitzungsskripte mit ShellCheck geprüft.
- mywm als Nix-Paket gebaut; alle 28 Rust-Tests bestanden.
- Gaming, Entwicklung und beide Profile gemeinsam vollständig ausgewertet;
  die optionalen Anwendungen wurden nicht zusätzlich vollständig gebaut.
- Die gebauten River-0.4.8-/mywm-/Quickshell-0.3.1-Pakete in einer isolierten
  Headless-Sitzung gestartet: deutsche Keymap, WM-IPC, Kanshi ohne Hardwareprofil,
  Bar und Wallpaper funktionieren beim Start. Qt verwendete für diesen Test
  Softwarerendering. Ohne PipeWire-Server in dieser isolierten Sitzung bleibt
  die Audioanbindung ungetestet; Login/PAM, GPU, Portale und Audio in der echten
  VM müssen noch geprüft werden.
