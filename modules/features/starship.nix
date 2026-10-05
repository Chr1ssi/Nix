{ ... }:

{
  # Modelled on https://github.com/Sin-cy/dotfiles (starship/.config/starship).
  flake.modules.homeManager.starship = {
    programs.starship = {
      enable = true;

      settings = {
        add_newline = false;
        command_timeout = 500;
        scan_timeout = 100;
        follow_symlinks = false;

        format = "$directory\${custom.giturl}$git_branch\${custom.git_worktree}$git_status$line_break$character";
        right_format = "$all";

        palette = "catppuccin_mocha";
        palettes.catppuccin_mocha = {
          crust = "#11111b";
          mantle = "#181825";
          base = "#1e1e2e";
          overlay2 = "#9399b2";
          overlay1 = "#7f849c";
          overlay0 = "#6c7086";
          surface2 = "#585b70";
          surface1 = "#45475a";
          surface0 = "#313244";
          text = "#cdd6f4";
          subtext1 = "#bac2de";
          subtext0 = "#a6adc8";
          rosewater = "#f5e0dc";
          flamingo = "#f2cdcd";
          pink = "#f5c2e7";
          mauve = "#cba6f7";
          red = "#f38ba8";
          maroon = "#eba0ac";
          peach = "#fab387";
          yellow = "#f9e2af";
          green = "#a6e3a1";
          teal = "#94e2d5";
          sky = "#89dceb";
          sapphire = "#74c7ec";
          blue = "#89b4fa";
          lavender = "#b4befe";
        };

        directory = {
          style = "teal";
          format = "[ $path ]($style)";
          truncation_length = 4;
          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = " ";
            "Pictures" = " ";
            "Projects" = "󰲋 ";
          };
        };

        line_break.disabled = true;

        character = {
          success_symbol = "[ ](bold fg:green)";
          error_symbol = "[✘ ](bold fg:red)";
          vimcmd_symbol = "[: ](bold fg:yellow)";
        };

        # The snippets use bash syntax; without `shell` starship would run them
        # in $STARSHIP_SHELL, i.e. fish.
        custom.giturl = {
          description = "Display symbol for remote Git server";
          command = ''
            GIT_REMOTE=$(command git ls-remote --get-url 2> /dev/null)
            if [[ "$GIT_REMOTE" =~ "github" ]]; then
                GIT_REMOTE_SYMBOL=" "
            elif [[ "$GIT_REMOTE" =~ "gitlab" ]]; then
                GIT_REMOTE_SYMBOL=" "
            elif [[ "$GIT_REMOTE" =~ "bitbucket" ]]; then
                GIT_REMOTE_SYMBOL=" "
            elif [[ "$GIT_REMOTE" =~ "git" ]]; then
                GIT_REMOTE_SYMBOL=" "
            else
                GIT_REMOTE_SYMBOL=" "
            fi
            echo "$GIT_REMOTE_SYMBOL "
          '';
          when = "git rev-parse --is-inside-work-tree 2> /dev/null";
          shell = [
            "bash"
            "--noprofile"
            "--norc"
          ];
          format = "$output";
          require_repo = true;
          ignore_timeout = true;
        };

        git_branch = {
          symbol = "[](base) ";
          style = "fg:lavender bg:base";
          format = "  [$symbol$branch]($style)[](base)";
        };

        custom.git_worktree = {
          description = "Show indicator when inside a git worktree";
          command = ''
            common_dir=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
            git_dir=$(git rev-parse --path-format=absolute --git-dir 2>/dev/null)
            if [ "$common_dir" != "$git_dir" ]; then
                echo "⛓ "
            fi
          '';
          when = "git rev-parse --is-inside-work-tree >/dev/null 2>&1";
          shell = [
            "bash"
            "--noprofile"
            "--norc"
          ];
          format = " ([$output ]($style))";
          style = "bold green";
          require_repo = true;
          ignore_timeout = true;
        };

        git_status = {
          format = "[$untracked$staged$modified$renamed$conflicted$ahead_behind ]($style)";
          staged = "[+](green)";
          modified = "[!](yellow)";
          renamed = "[»](blue)";
          deleted = "[-](red)";
          untracked = "[?](red)";
          stashed = "[≡](lavender)";
          conflicted = "[✖](red bold)";
          ahead = "[⇡\${count}](teal)";
          behind = "[⇣\${count}](peach)";
          diverged = "[⇕⇡\${ahead_count}⇣\${behind_count}](mauve)";
        };

        username.disabled = true;
        time.disabled = true;
        os.disabled = true;

        cmd_duration = {
          min_time = 2000;
          format = "[󱑆 $duration]($style) ";
          style = "bold yellow";
        };

        nix_shell = {
          format = "[ $symbol$state( \\($name\\)) ]($style)";
          symbol = "󱄅 ";
          style = "bold sky";
          heuristic = true;
        };

        nodejs = {
          symbol = "";
          format = "[ $symbol( $version) ]($style)";
        };

        bun.detect_files = [
          "bun.lock"
          "bun.lockb"
        ];

        c = {
          symbol = " ";
          format = "[ $symbol( $version) ]($style)";
        };

        rust = {
          symbol = "";
          format = "[ $symbol( $version) ]($style)";
        };

        golang = {
          symbol = "";
          format = "[ $symbol( $version) ]($style)";
          detect_files = [ "go.mod" ];
        };

        php = {
          symbol = "";
          format = "[ $symbol( $version) ]($style)";
        };

        java = {
          symbol = " ";
          format = "[ $symbol( $version) ]($style)";
        };

        kotlin = {
          symbol = "";
          format = "[ $symbol( $version) ]($style)";
        };

        haskell = {
          symbol = "";
          format = "[ $symbol( $version) ]($style)";
        };

        python = {
          symbol = "";
          format = "[ $symbol( $version) ]($style)";
        };

        docker_context = {
          symbol = "";
          format = "[ $symbol( $context) ]($style)";
        };
      };
    };
  };
}
