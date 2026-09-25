{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,

  cacert,
  glib,
  glib-networking,
  gtk3,
  webkitgtk_4_1,
  libsoup_3,
  openssl,
  libayatana-appindicator,
}:

stdenv.mkDerivation rec {
  pname = "opendeck";
  version = "2.14.0";

  src = fetchurl {
    url = "https://github.com/nekename/OpenDeck/releases/download/v${version}/opendeck_${version}_amd64.deb";
    hash = "sha256-tBOCcRMOop3GrO2D/X4wGBplmTUdj9L6ye2aeLq+plY=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    glib
    gtk3
    webkitgtk_4_1
    libsoup_3
    openssl
    libayatana-appindicator
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/* $out/

    mkdir -p $out/lib/udev/rules.d

    cat > $out/lib/udev/rules.d/70-streamdeck.rules <<'EOF'
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", TAG+="uaccess"
    EOF

    runHook postInstall
  '';

  postFixup = ''
    # OpenDeck loads AppIndicator with dlopen, so autoPatchelf cannot discover
    # it and the library must be exposed explicitly at runtime.
    # WebKitGTK 2.52 collapses OpenDeck's flex-contained canvases to their
    # borders on the native Wayland backend. The X11 backend renders the
    # 5x3 key grid at its intended size under XWayland.
    # WebKit loads the HTTPS plugin catalogues through GIO/libsoup, so expose
    # both the TLS backend and the CA bundle explicitly on NixOS.
    wrapProgram "$out/bin/opendeck" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libayatana-appindicator ]} \
      --prefix GIO_EXTRA_MODULES : ${glib-networking}/lib/gio/modules \
      --set-default SSL_CERT_FILE ${cacert}/etc/ssl/certs/ca-bundle.crt \
      --set-default GDK_BACKEND x11
  '';

  meta = {
    description = "Linux software for the Elgato Stream Deck";
    homepage = "https://github.com/nekename/OpenDeck";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "opendeck";
  };
}
