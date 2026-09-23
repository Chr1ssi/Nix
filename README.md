# NixOS and macOS Configuration

Meine deklarative Konfiguration für NixOS und macOS, aufgebaut mit **Nix Flakes**, **Home Manager** und **nix-darwin**. Das Repository enthält ein modulares System für Desktop, Gaming, Entwicklung und persistente Daten.

Das Repository dient als zentrale Definition meiner Linux- und macOS-Systeme. Systemkonfiguration, Benutzerumgebung, Anwendungen, Dotfiles und eigene Pakete werden möglichst vollständig über Nix verwaltet.

Der Desktop basiert auf meinem eigenen Wayland-Setup mit **River**, **mywm** und **Quickshell**.

## Ziele

Das Setup verfolgt einige grundlegende Prinzipien:

- reproduzierbare und deklarative Systemkonfiguration
- möglichst wenig manuell verwalteter Systemzustand
- gemeinsame Module für VM und physische Hardware
- eigener minimalistischer Wayland-Desktop
- Gaming ohne unnötige Desktop-Abhängigkeiten
- kontrollierte Persistence statt dauerhaft veränderlichem Root-Dateisystem
- eigene Nix-Pakete für Software, die nicht passend in nixpkgs verfügbar ist

Die Konfiguration befindet sich weiterhin in aktiver Entwicklung. Der VM-Host dient zum Testen der NixOS-Struktur, bevor der bestehende CachyOS-Desktop vollständig durch NixOS ersetzt wird.

---

## Hosts

Die Flake stellt aktuell zwei NixOS-Konfigurationen und eine nix-darwin-Konfiguration bereit.

### `vm`

Testsystem für die Entwicklung und Validierung der Konfiguration.

Die VM wird verwendet, um Änderungen an NixOS, Home Manager, mywm und der Persistence zu testen, ohne das produktive Desktop-System zu beeinflussen.

### `desktop`

Zielkonfiguration für die physische Workstation.

Sie enthält zusätzlich die für den realen Desktop benötigten Komponenten wie Gaming, Hardwareintegration und Desktop-Anwendungen.

Die Konfiguration lässt sich bereits vollständig evaluieren und bauen. Der vollständige Betrieb auf der finalen Hardware wird erst mit der eigentlichen Migration von CachyOS auf NixOS abgeschlossen.

### `mac`

nix-darwin-Konfiguration für den Apple-Silicon-Mac. Home Manager verwaltet dort die gemeinsame Entwicklungsumgebung und die macOS-spezifischen Anwendungen. NixOS verwendet Fish als Login-Shell; macOS bleibt bei der nativen Zsh unter `/bin/zsh`.

---

## Repository-Struktur

```text
.
├── flake.nix
├── flake.lock
│
├── modules/
│   ├── nixos/
│   │   ├── base.nix
│   │   ├── desktop.nix
│   │   ├── gaming.nix
│   │   ├── development.nix
│   │   └── ...
│   │
│   └── home/
│       ├── essentials.nix
│       ├── essentials-mac.nix
│       ├── fish.nix
│       ├── zsh.nix
│       ├── mywm.nix
│       ├── development.nix
│       └── ...
│
├── packages/
│   ├── mywm.nix
│   ├── helium.nix
│   ├── opendeck.nix
│   └── ...
│
├── dotfiles/
├── scripts/
└── wallpapers/
```

### `modules/nixos`

Systemweite NixOS-Konfiguration.

Hier befinden sich unter anderem:

- Basissystem
- Boot- und Storage-Konfiguration
- Netzwerk
- Desktop-Session
- Audio
- udev und Hardwareintegration
- Gaming
- Entwicklungsumgebung
- Persistence

### `modules/home`

Benutzerspezifische Konfiguration über Home Manager.

Dazu gehören unter anderem:

- Terminal
- Browser
- Desktop-Anwendungen
- MIME-Zuordnungen
- Dotfiles
- mywm-Konfiguration
- Entwicklungswerkzeuge

Home Manager wird über die jeweilige NixOS- bzw. nix-darwin-Konfiguration eingebunden. Ein separater `home-manager switch` ist daher nicht notwendig.

### `packages`

Eigene Nix-Derivations für Software, die nicht direkt oder nicht in der gewünschten Form aus nixpkgs verwendet wird.

Aktuell gehören dazu unter anderem:

- `mywm`
- Helium
- OpenDeck

### `dotfiles`

Deklarativ übernommene Anwendungskonfigurationen.

Persistente Laufzeitdaten, Accounts, Tokens und vergleichbare zustandsbehaftete Daten gehören dagegen nicht in dieses Verzeichnis.

---

# Desktop

## Wayland

Der Desktop ist bewusst als schlankes Wayland-System aufgebaut.

Die zentrale Komponente ist **River**, dessen Window-Management-Protokolle von meinem eigenen Window Manager **mywm** verwendet werden.

Die Desktop-Shell basiert auf **Quickshell**.

Die einzelnen Komponenten werden getrennt entwickelt und über die Flake als feste Inputs eingebunden.

### mywm

`mywm` ist mein eigener Window Manager auf Basis der River-Protokolle.

Das Projekt übernimmt unter anderem:

- Window Management
- Workspaces
- Fokussteuerung
- Keybindings
- Output-Verwaltung
- Integration mit der Desktop-Shell

Die benutzerspezifische Konfiguration befindet sich in:

```text
modules/home/mywm.nix
```

Der Anwendungscode selbst wird nicht in diesem Repository gepflegt, sondern als Flake-Input eingebunden.

### Quickshell

Quickshell stellt die grafische Desktop-Shell bereit.

Dazu gehören Desktop-Komponenten wie Bar, Launcher und weitere UI-Elemente.

Die Shell wird unabhängig vom NixOS-Repository entwickelt und ebenfalls über einen gepinnten Flake-Input eingebunden.

### Session

Die grafische Sitzung wird über `greetd` gestartet.

Das Session-Setup kümmert sich anschließend um die benötigten Wayland-Komponenten und die Integration mit systemd und D-Bus.

Zum Desktop gehören außerdem unter anderem:

- PipeWire
- xdg-desktop-portals
- Polkit-Agent
- Benachrichtigungen
- Screen Lock
- Kanshi
- Wallpaper-Integration

Xwayland bleibt verfügbar, wenn Anwendungen es benötigen.

---

# Storage und Impermanence

Das Desktop-System verwendet Btrfs.

Der Root-Zustand ist bewusst kurzlebig: Beim Booten wird das Root-Subvolume zurückgesetzt, sodass Änderungen außerhalb der explizit persistenten Bereiche nicht dauerhaft erhalten bleiben.

Damit bleibt das laufende System weitgehend aus der Nix-Konfiguration reproduzierbar.

Persistente Daten werden getrennt vom kurzlebigen Root verwaltet.

Dazu gehören beispielsweise:

- Benutzerdateien
- ausgewählte Systemzustände
- Logs
- notwendige Anwendungsdaten
- Passwortinformationen

`journald` wird persistent gespeichert, sodass Logs auch nach einem Root-Rollback und Neustart verfügbar bleiben.

Alte Root-Zustände können kurzfristig als Btrfs-Subvolumes aufbewahrt und anschließend automatisch bereinigt werden.

Das Ziel ist dabei nicht vollständige Zustandslosigkeit, sondern eine klare Trennung zwischen:

```text
deklarativem Systemzustand
        +
explizit persistentem Laufzeitzustand
```

---

# Anwendungen

## Browser

### Helium

**Helium** ist der primäre Browser und als Standardbrowser für HTTP, HTTPS und HTML registriert.

Da Helium nicht alle DRM-/Widevine-Anwendungsfälle unterstützt, wird zusätzlich Firefox installiert.

### Firefox

Firefox dient hauptsächlich als Fallback für DRM-geschützte Streaming-Dienste wie Netflix.

Helium bleibt trotzdem der Standardbrowser des Systems.

Das Helium-Paket wird lokal über

```text
packages/helium.nix
```

gebaut.

Dabei wird das offizielle Linux-Binary in eine Nix-Derivation integriert und für NixOS gepatcht.

---

## OpenRGB

OpenRGB übernimmt die RGB-Steuerung der Desktop-Hardware.

Im Gegensatz zu einigen anderen Anwendungen wird die vorhandene OpenRGB-Konfiguration vom bisherigen CachyOS-System übernommen.

Die Hardwareintegration erfolgt systemweit über NixOS einschließlich der benötigten udev-Regeln.

---

## OpenDeck

OpenDeck wird über eine eigene Derivation bereitgestellt:

```text
packages/opendeck.nix
```

Das offizielle Debian-Paket wird von Nix heruntergeladen, entpackt und für die NixOS-Laufzeitumgebung gepatcht.

Das Paket enthält zusätzlich eine generische udev-Regel für Elgato-Geräte:

```udev
SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", TAG+="uaccess"
```

Die Regel wird über `services.udev.packages` in das NixOS-System eingebunden.

Dadurch kann OpenDeck ohne Root-Rechte auf das Stream Deck zugreifen.

Die bestehende OpenDeck-Konfiguration von CachyOS wird bewusst **nicht** übernommen. OpenDeck wird nach der Migration frisch eingerichtet; anschließend werden die tatsächlich benötigten Laufzeitdaten persistent gemacht.

---

# Gaming

Die Desktop-Konfiguration enthält ein eigenes Gaming-Modul.

Dazu gehören unter anderem:

- Steam
- Heroic Games Launcher
- Vesktop
- GameMode
- MangoHud
- notwendige 32-Bit-Grafikunterstützung

GameMode kann Spielen temporär optimierte Systemressourcen zur Verfügung stellen.

MangoHud dient zur Anzeige von Performance-Informationen wie FPS, Frametimes und Hardwareauslastung.

Gamescope ist nicht zwingender Bestandteil des Setups und wird nur ergänzt, wenn ein konkreter Anwendungsfall dafür entsteht.

---

# Entwicklung

Die Entwicklungsumgebung wird ebenfalls deklarativ verwaltet.

Sie enthält unter anderem Werkzeuge für:

- Rust
- Python
- Node.js
- Git
- Neovim / LazyVim
- VS Code
- Compiler- und Build-Werkzeuge
- CLI- und Suchwerkzeuge

Allgemeine Werkzeuge gehören in die System- bzw. Home-Konfiguration.

Projektabhängige Toolchains und SDKs sollen dagegen bevorzugt über projektspezifische Nix-Devshells bereitgestellt werden.

---

# Dotfiles

Ein Teil der bestehenden CachyOS-Konfiguration wurde in das Repository übernommen.

Dazu gehören beispielsweise Einstellungen für:

- Kitty
- Neovim / LazyVim
- GTK
- Vesktop
- OpenRGB

Dabei wird zwischen **deklarativer Konfiguration** und **Laufzeitdaten** unterschieden.

Accounts, Tokens, Sessions und andere sensible oder veränderliche Daten werden nicht einfach als Dotfiles ins Repository übernommen.

---

# Flake Inputs

Die Konfiguration verwendet Nix Flakes.

`flake.lock` fixiert die verwendeten Versionen und Commits, wodurch Builds reproduzierbar bleiben.

Neben nixpkgs und Home Manager werden auch die eigenen Desktop-Projekte als Inputs eingebunden.

Dadurch benötigt ein normaler System-Build keine benachbarten Git-Checkouts von `mywm` oder der Quickshell-Konfiguration.

Änderungen an diesen Projekten werden erst übernommen, wenn der entsprechende Flake-Input aktualisiert wird.

---

# Build

## Desktop

Die Desktop-Konfiguration kann gebaut werden mit:

```sh
nix build .#nixosConfigurations.desktop.config.system.build.toplevel
```

Falls die experimentellen Features nicht global aktiviert sind:

```sh
nix build .#nixosConfigurations.desktop.config.system.build.toplevel \
  --extra-experimental-features "nix-command flakes"
```

## VM

Analog lässt sich die VM-Konfiguration bauen:

```sh
nix build .#nixosConfigurations.vm.config.system.build.toplevel
```

## macOS

Die macOS-Konfiguration lässt sich vor der Aktivierung evaluieren bzw. bauen:

```sh
nix build .#darwinConfigurations.mac.system
```

---

# System aktualisieren

Zunächst die gewünschten Flake-Inputs aktualisieren:

```sh
nix flake update
```

Danach kann die entsprechende NixOS-Konfiguration gebaut bzw. aktiviert werden.

Auf dem Desktop:

```sh
sudo nixos-rebuild switch --flake .#desktop
```

In der VM:

```sh
sudo nixos-rebuild switch --flake .#vm
```

Auf macOS:

```sh
darwin-rebuild switch --flake .#mac
```

Vor einem Switch kann die Konfiguration ohne Aktivierung geprüft werden:

```sh
nix build .#nixosConfigurations.desktop.config.system.build.toplevel
```
