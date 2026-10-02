{ config, inputs, ... }:

{
  flake.modules.nixos.development = {
    nixpkgs.config.allowUnfree = true;

    # Zed extensions download conventional Linux binaries (language servers).
    programs.nix-ld.enable = true;

    home-manager.sharedModules = [ config.flake.modules.homeManager.development ];
  };

  flake.modules.homeManager.development =
    { lib, pkgs, ... }:
    let
      visPlugins = {
        vis-cursors = pkgs.fetchFromGitHub {
          owner = "erf";
          repo = "vis-cursors";
          rev = "ddea23c7a19f70316bc3431efbade49aca39f474";
          hash = "sha256-ij/78EEKnZ+XVIgIkXqFzsD4L3Xbz8bjqBLhLCRcdBA=";
        };
        vis-fzf-open = pkgs.fetchFromGitHub {
          owner = "guillaumecherel";
          repo = "vis-fzf-open";
          rev = "d190b233e4a89e92837e065594e70988dc758444";
          hash = "sha256-MRsdjI5zjhZhwZO1rppKpIxRjSujG3ZVg2fSg612rPY=";
        };
      };
    in
    {
      programs.git.enable = true;

      home.sessionVariables = {
        EDITOR = "vis";
        VISUAL = "vis";
      };

      xdg.configFile = {
        "vis/visrc.lua".source = ../../dotfiles/vis/visrc.lua;
      }
      // lib.mapAttrs' (name: src: lib.nameValuePair "vis/plugins/${name}" { source = src; }) visPlugins;

      programs.zed-editor = {
        enable = true;

        extensions = [
          "nix"
          "toml"
        ];

        userSettings = {
          cli_default_open_behavior = "existing_window";
          base_keymap = "JetBrains";

          project_panel.dock = "left";

          telemetry = {
            diagnostics = false;
            metrics = false;
            anthropic_retention = false;
          };

          session.trust_all_worktrees = true;

          theme = {
            mode = "dark";
            light = "One Light";
            dark = "Ayu Dark";
          };

          languages.Nix.language_servers = [
            "nixd"
            "nil"
          ];

          lsp = {
            nixd.binary.path = "${pkgs.nixd}/bin/nixd";
            nil.binary.path = "${pkgs.nil}/bin/nil";
          };
        };

        extraPackages = with pkgs; [
          nixd
          nil
          nixfmt
          rust-analyzer
          rustc
          cargo
          python3
          nodejs
        ];
      };

      programs.git.settings = {
        user = {
          name = "Christoph Keil";
          email = "mail@christoph-keil.com";
        };

        core.editor = "vis";
      };

      home.packages = with pkgs; [
        inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.desktop
        vis
        fzf
        ripgrep
        fd
        jq
        gcc
        gnumake
        pkg-config
        rustc
        cargo
        rust-analyzer
        python3
        nodejs
        nil
        nixfmt
        unzip
      ];
    };
}
