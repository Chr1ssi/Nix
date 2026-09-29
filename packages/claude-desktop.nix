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
  libcap_ng,
  libseccomp,
  libsecret,
  libGL,
  addDriverRunpath,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
  util-linux,
  vulkan-loader,
  xdg-utils,

  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libXrandr,
  libXrender,
  libXtst,
  libxcb,
}:

stdenv.mkDerivation rec {
  pname = "claude-desktop";
  version = "2.9939.4";

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${version}_amd64.deb";
    hash = "sha256-PP3bI78pEeBeJ7TtOFa455XflGQ7LDW1nesxfPmVvKA=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  dontWrapGApps = true;

  # Chromium dlopen()s libsecret for the keyring backend, so DT_NEEDED alone
  # would not put it on the RUNPATH.
  runtimeDependencies = [ libsecret ];

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
    libcap_ng
    libseccomp
    libsecret
    libxkbcommon
    mesa
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    systemd
    util-linux
    vulkan-loader

    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libxcb
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --fsys-tarfile "$src" | tar --no-same-permissions -x
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib" "$out/share" "$out/bin"
    cp -r usr/lib/claude-desktop "$out/lib/"
    cp -r usr/share/applications "$out/share/"
    cp -r usr/share/icons "$out/share/"

    substituteInPlace "$out/share/applications/com.anthropic.Claude.desktop" \
      --replace-warn "Exec=claude-desktop" "Exec=$out/bin/claude-desktop"

    runHook postInstall
  '';

  preFixup = ''
    makeWrapper "$out/lib/claude-desktop/claude-desktop" "$out/bin/claude-desktop" \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libGL ]}:${addDriverRunpath.driverLink}/lib" \
      --add-flags "--password-store=gnome-libsecret" \
      "''${gappsWrapperArgs[@]}"
  '';

  meta = {
    description = "Official Claude desktop app with Claude Code support";
    homepage = "https://claude.com/download";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "claude-desktop";
  };
}
