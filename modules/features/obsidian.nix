{ ... }:

{
  flake.modules.homeManager.obsidian =
    { pkgs, ... }:
    let
      version = "1.0.30";
      releaseAsset =
        name: hash:
        pkgs.fetchurl {
          url = "https://github.com/vrtmrz/obsidian-livesync/releases/download/${version}/${name}";
          inherit hash;
        };
      liveSync =
        pkgs.runCommand "obsidian-livesync-${version}"
          {
            passthru.manifestId = "obsidian-livesync";
          }
          ''
            mkdir -p "$out"
            cp ${releaseAsset "main.js" "sha256-WyBQ7kEFmu7yrRMff6TdiBlMWhX6QCxBQxI3UwirTwQ="} "$out/main.js"
            cp ${releaseAsset "manifest.json" "sha256-8kPExcweWbJtEMCs2sjetSn70+Eg5JBFHRON/lbx4RM="} "$out/manifest.json"
            cp ${releaseAsset "styles.css" "sha256-S6AL70F+6Y2aYt2f67eS3GVVlJz8no4GlFCtaZqyufA="} "$out/styles.css"
          '';
    in
    {
      programs.obsidian = {
        enable = true;
        package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.obsidian;

        defaultSettings.appearance.baseTheme = "dark";

        defaultSettings.communityPlugins = [
          liveSync
        ];

        vaults.notes.target = "Documents/Obsidian";
      };
    };
}
