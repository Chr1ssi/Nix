{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,

  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libsecret,
  libusb1,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  openssl,
  pango,
  systemd,
  tpm2-tss,
  vulkan-loader,
  xdg-utils,
  git,

  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libXrandr,
  libXrender,
  libxcb,
}:

stdenv.mkDerivation rec {
  pname = "chatgpt";
  version = "26.917.71314";

  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${version}_amd64.deb";
    hash = "sha256-hR7Ci2W94v8dqfN9zfW24gqRXHVo+LLOmTwAQo8BiuU=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  # The Electron binary creates a native GTK file chooser. Without the
  # GSettings environment supplied by wrapGAppsHook it aborts when a project
  # folder is selected.
  dontWrapGApps = true;

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libsecret
    libusb1
    libxkbcommon
    mesa
    nspr
    nss
    openssl
    pango
    stdenv.cc.cc.lib
    systemd
    tpm2-tss
    vulkan-loader

    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libxcb
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
    "libc.musl-x86_64.so.1"
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib" "$out/share" "$out/bin"
    cp -r usr/lib/chatgpt "$out/lib/"
    cp -r usr/share/applications "$out/share/"
    cp -r usr/share/metainfo "$out/share/"
    cp -r usr/share/pixmaps "$out/share/"

    substituteInPlace "$out/share/applications/chatgpt.desktop" \
      --replace-fail "Exec=chatgpt" "Exec=$out/bin/chatgpt"

    runHook postInstall
  '';

  preFixup = ''
    makeWrapper "$out/lib/chatgpt/ChatGPT" "$out/bin/chatgpt" \
      --prefix PATH : ${lib.makeBinPath [ git xdg-utils ]} \
      --add-flags "--ozone-platform=wayland" \
      "''${gappsWrapperArgs[@]}"
  '';

  meta = {
    description = "Official ChatGPT desktop app for Linux";
    homepage = "https://learn.chatgpt.com/docs/linux/linux-app";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "chatgpt";
  };
}
