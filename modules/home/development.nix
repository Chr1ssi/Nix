{ inputs, ... }:

{
  flake.modules.homeManager.development =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };

      programs.zed-editor = {
        enable = true;

        extensions = [
          "nix"
          "toml"
        ];

        userSettings = {
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

        core.editor = "nvim";
      };

      xdg.configFile."nvim/init.lua".source = ../../dotfiles/nvim/init.lua;

      xdg.configFile."nvim/lua" = {
        source = ../../dotfiles/nvim/lua;
        recursive = true;
      };

      xdg.configFile."nvim/stylua.toml".source = ../../dotfiles/nvim/stylua.toml;

      home.activation.seedLazyVim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p \
          ${lib.escapeShellArg "${config.xdg.configHome}/nvim"} \
          ${lib.escapeShellArg "${config.xdg.stateHome}/nvim"}

        if [ ! -e ${lib.escapeShellArg "${config.xdg.configHome}/nvim/lazyvim.json"} ]; then
          run install -m 644 \
            ${../../dotfiles/nvim/lazyvim.json} \
            ${lib.escapeShellArg "${config.xdg.configHome}/nvim/lazyvim.json"}
        fi

        if [ ! -e ${lib.escapeShellArg "${config.xdg.stateHome}/nvim/lazy-lock.json"} ]; then
          run install -m 644 \
            ${../../dotfiles/nvim/lazy-lock.json} \
            ${lib.escapeShellArg "${config.xdg.stateHome}/nvim/lazy-lock.json"}
        fi
      '';

      home.packages = with pkgs; [
        inputs.hermes-agent.packages.${pkgs.system}.default
        inputs.hermes-agent.packages.${pkgs.system}.desktop
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
        tree-sitter
        unzip
      ];
    };
}
