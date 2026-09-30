{
  lib,
  rustPlatform,
  pkg-config,
  makeWrapper,
  libxkbcommon,
  libinput,
  seatd,
  libgbm,
  libdrm,
  systemd,
  wayland,
  libGL,
  vulkan-loader,
  src,
}:

rustPlatform.buildRustPackage {
  pname = "mywm-compositor";
  version = "0.1.0";

  inherit src;

  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    libxkbcommon
    libinput
    seatd
    libgbm
    libdrm
    systemd
    wayland
    libGL
  ];

  # The tests need a display and hardware that the build sandbox does not have.
  doCheck = false;

  # smithay loads EGL and friends at runtime.
  postFixup = ''
    wrapProgram $out/bin/mywm-compositor \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libGL
          vulkan-loader
          wayland
          libxkbcommon
          libgbm
          libdrm
        ]
      }
  '';

  meta = {
    description = "Smithay-based Wayland compositor for mywm";
    homepage = "https://github.com/Chr1ssi/MyWM-smithey";
    mainProgram = "mywm-compositor";
    platforms = lib.platforms.linux;
  };
}
