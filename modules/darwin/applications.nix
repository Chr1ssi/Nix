{ ... }:

{
  flake.modules.darwin.applications =
    { lib, ... }:
    {
      system.activationScripts.postActivation.text = lib.mkAfter ''
        sourceDirectory='/Users/chris/Applications/Home Manager Apps'
        targetDirectory='/Applications'

        # Remove only stale links previously managed by this module.
        find "$targetDirectory" -maxdepth 1 -type l -name '*.app' -print0 |
          while IFS= read -r -d $'\0' targetPath; do
            linkTarget="$(readlink "$targetPath")"

            case "$linkTarget" in
              "$sourceDirectory"/*)
                if [ ! -d "$linkTarget" ]; then
                  rm "$targetPath"
                fi
                ;;
            esac
          done

        if [ -d "$sourceDirectory" ]; then
          for appBundle in "$sourceDirectory"/*.app; do
            [ -d "$appBundle" ] || continue

            targetPath="$targetDirectory/''${appBundle##*/}"

            if [ -e "$targetPath" ] || [ -L "$targetPath" ]; then
              linkTarget="$(readlink "$targetPath" 2>/dev/null || true)"

              case "$linkTarget" in
                "$sourceDirectory"/*)
                  ;;
                *)
                  echo "leaving existing application untouched: $targetPath" >&2
                  continue
                  ;;
              esac
            fi

            ln -sfn "$appBundle" "$targetPath"
          done
        fi

        # nix-darwin creates this directory for system packages. Keep it only
        # when it actually contains an application.
        rmdir '/Applications/Nix Apps' 2>/dev/null || true
      '';
    };
}
