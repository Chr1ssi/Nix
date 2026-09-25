{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  symlinkJoin,

  cargo-tauri,
  deno,
  makeWrapper,
  pkg-config,
  wrapGAppsHook3,
  writableTmpDirAsHomeHook,

  glib-networking,
  gtk3,
  webkitgtk_4_1,
  libsoup_3,
  openssl,
  libayatana-appindicator,
  systemd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "opendeck";
  version = "2.14.0";

  src = fetchFromGitHub {
    owner = "nekename";
    repo = "OpenDeck";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2zI1asMPLxllKaDaCaGbIZ1PwiQJCCsiuyG/gUKe0Mk=";
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = "src-tauri";
  cargoDeps = symlinkJoin {
    name = "opendeck-cargo-deps";
    paths = [
      (rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) pname version src;
        cargoRoot = "src-tauri";
        hash = "sha256-AZ32cl5qbq/lROow9CpBgl3eztLos7VMqOnQV4kdvJU=";
      })
      (rustPlatform.fetchCargoVendor {
        name = "opendeck-starterpack-";
        inherit (finalAttrs) src;
        cargoRoot = "plugins/com.amansprojects.starterpack.sdPlugin";
        hash = "sha256-s8GPWbPMJY9XTTC4QajY2sYUXcJ0g2OSl/YYhK/UZLQ=";
      })
    ];
  };

  nodeModules = stdenv.mkDerivation {
    pname = "opendeck-node-modules";
    inherit (finalAttrs) version src;

    nativeBuildInputs = [
      deno
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;
    dontFixup = true;
    dontPatchShebangs = true;

    buildPhase = ''
      runHook preBuild
      export DENO_DIR="$PWD/.deno-dir"
      deno install --frozen
      (
        cd plugins/com.amansprojects.starterpack.sdPlugin
        mkdir -p target
        deno cache --lock=target/deno.lock build.ts
      )
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -R node_modules $out/node_modules
      cp -R .deno-dir $out/deno-dir
      cp plugins/com.amansprojects.starterpack.sdPlugin/target/deno.lock $out/plugin-deno.lock
      runHook postInstall
    '';

    outputHash = "sha256-NDEDmki0dP0xqEKN21RrAFeeAaLL5kYTuZcNraxhkTg=";
    outputHashMode = "recursive";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    deno
    makeWrapper
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib-networking
    gtk3
    webkitgtk_4_1
    libsoup_3
    openssl
    libayatana-appindicator
    systemd
  ];

  env.OPENDECK_DISABLE_UPDATE_CHECK = "1";

  configurePhase = ''
    runHook preConfigure

    cp -R ${finalAttrs.nodeModules}/node_modules node_modules
    cp -R ${finalAttrs.nodeModules}/deno-dir .deno-dir
    chmod -R u+rw .deno-dir
    export DENO_DIR="$PWD/.deno-dir"
    mkdir -p plugins/com.amansprojects.starterpack.sdPlugin/target
    cp ${finalAttrs.nodeModules}/plugin-deno.lock plugins/com.amansprojects.starterpack.sdPlugin/target/deno.lock
    chmod -R u+rw node_modules
    export PATH="$PWD/node_modules/.bin:$PATH"

    runHook postConfigure
  '';

  postInstall = ''
    mkdir -p $out/lib/udev/rules.d
    cat > $out/lib/udev/rules.d/70-streamdeck.rules <<'EOF'
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", TAG+="uaccess"
    EOF
  '';

  postFixup = ''
    # WebKitGTK 2.52 collapses OpenDeck's flex-contained canvases to their
    # borders on the native Wayland backend. The X11 backend renders the
    # 5x3 key grid at its intended size under XWayland.
    wrapProgram "$out/bin/opendeck" \
      --set-default GDK_BACKEND x11
  '';

  meta = {
    description = "Linux software for the Elgato Stream Deck";
    homepage = "https://github.com/nekename/OpenDeck";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "opendeck";
  };
})
