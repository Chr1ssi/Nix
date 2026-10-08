{
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "slot-nord-dark-colorize-icons";
  version = "0-unstable-2026-07-07";

  src = fetchFromGitHub {
    owner = "L4ki";
    repo = "Slot-Plasma-Themes";
    rev = "ac0382d7bf096d4e061934691cd5f4543b02aac4";
    hash = "sha256-xTFKvZfYzOujTMKObJ4UZEi1n0fjvP4BSmAJmklw8Us=";
  };

  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    mkdir -p $out/share/icons
    cp -r "Slot Icons Themes/Slot-Nord-Dark-Colorize-Icons" $out/share/icons/
  '';
}
