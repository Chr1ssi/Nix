{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,

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
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  systemd,

  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libxcb,
}:

stdenv.mkDerivation rec {
  pname = "helium";
  version = "0.17.2.1";

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64_linux.tar.xz";
    hash = "sha256-KmOd9U49BfQTz7tGIqTRpoWEsx2lp6r1juPNg8fD4pk=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

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
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd

    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
  ];

  sourceRoot = "helium-${version}-x86_64_linux";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/helium
    cp -r . $out/opt/helium/

    mkdir -p $out/bin
    ln -s $out/opt/helium/helium $out/bin/helium

    mkdir -p $out/share/applications
    cp helium.desktop $out/share/applications/helium.desktop

    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp product_logo_256.png \
      $out/share/icons/hicolor/256x256/apps/helium.png

    substituteInPlace $out/share/applications/helium.desktop \
      --replace-fail "Exec=helium" "Exec=$out/bin/helium" \
      --replace-fail "Icon=helium" "Icon=helium"

    runHook postInstall
  '';

  meta = {
    description = "Private, fast, Chromium-based web browser";
    homepage = "https://helium.computer/";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "helium";
  };
}
