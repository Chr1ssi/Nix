{ lib, rustPlatform, makeWrapper, src, shellSrc, quickshell, libxkbcommon,
  swaylock, swayidle, wlopm, systemd }:
rustPlatform.buildRustPackage {
  pname = "mywm";
  version = "0.1.0";
  src = lib.cleanSourceWith {
    inherit src;
    filter = path: type:
      !(builtins.elem (builtins.baseNameOf path) [ ".git" "target" "quickshell" ]);
  };
  cargoLock.lockFile = src + "/Cargo.lock";
  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ libxkbcommon ];
  postPatch = ''
    substituteInPlace src/river.rs \
      --replace-fail /usr/share/river-protocols/stable ${./river-protocols}
  '';
  postInstall = ''
    mkdir -p $out/share/mywm/quickshell
    cp -r ${shellSrc}/quickshell/. $out/share/mywm/quickshell/
    wrapProgram $out/bin/mywm \
      --set-default MYWM_SHELL_DIR $out/share/mywm/quickshell \
      --prefix PATH : ${lib.makeBinPath [ quickshell libxkbcommon swaylock swayidle wlopm systemd ]}
  '';
  meta = {
    description = "Custom River window manager with its Quickshell UI";
    mainProgram = "mywm";
    platforms = lib.platforms.linux;
  };
}
