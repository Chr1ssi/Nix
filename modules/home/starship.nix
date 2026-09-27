{ ... }:

{
  flake.modules.homeManager.starship = {
    programs.starship = {
      enable = true;

      settings = {
        add_newline = true;
        command_timeout = 800;
        scan_timeout = 30;

        format = "$username$hostname$directory$git_branch$git_status$nix_shell$rust$nodejs$python$golang$container$line_break$character";
        right_format = "$status$cmd_duration$jobs$time";

        palette = "catppuccin_mocha";
        palettes.catppuccin_mocha = {
          rosewater = "#f5e0dc";
          flamingo = "#f2cdcd";
          pink = "#f5c2e7";
          mauve = "#cba6f7";
          red = "#f38ba8";
          peach = "#fab387";
          yellow = "#f9e2af";
          green = "#a6e3a1";
          teal = "#94e2d5";
          sky = "#89dceb";
          sapphire = "#74c7ec";
          blue = "#89b4fa";
          lavender = "#b4befe";
          text = "#cdd6f4";
          subtext0 = "#a6adc8";
          surface1 = "#45475a";
        };

        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
          vimcmd_symbol = "[❮](bold mauve)";
        };

        directory = {
          format = "[󰉋  $path]($style)[$read_only]($read_only_style) ";
          style = "bold blue";
          read_only = " 󰌾";
          truncation_length = 4;
          truncate_to_repo = false;
        };

        git_branch = {
          format = "on [$symbol$branch(:$remote_branch)]($style) ";
          symbol = " ";
          style = "bold mauve";
          truncation_length = 28;
        };

        git_status = {
          format = "([$all_status$ahead_behind]($style) )";
          style = "bold peach";
          conflicted = "=\${count}";
          ahead = "⇡\${count}";
          behind = "⇣\${count}";
          diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
          untracked = "?\${count}";
          stashed = "*\${count}";
          modified = "!\${count}";
          staged = "+\${count}";
          renamed = "»\${count}";
          deleted = "✘\${count}";
        };

        nix_shell = {
          format = "via [$symbol$state( \\($name\\))]($style) ";
          symbol = "󱄅 ";
          style = "bold sky";
          heuristic = true;
        };

        rust = {
          format = "via [$symbol($version )]($style)";
          symbol = " ";
          style = "bold peach";
          version_format = "\${major}.\${minor}";
        };

        nodejs = {
          format = "via [$symbol($version )]($style)";
          symbol = " ";
          style = "bold green";
          version_format = "\${major}.\${minor}";
        };

        python = {
          format = "via [$symbol$pyenv_prefix($version )(\\($virtualenv\\) )]($style)";
          symbol = " ";
          style = "bold yellow";
          version_format = "\${major}.\${minor}";
        };

        golang = {
          format = "via [$symbol($version )]($style)";
          symbol = " ";
          style = "bold sapphire";
          version_format = "\${major}.\${minor}";
        };

        container = {
          format = "in [$symbol$name]($style) ";
          symbol = " ";
          style = "bold red";
        };

        username = {
          format = "[$user]($style)@";
          style_user = "bold lavender";
          style_root = "bold red";
          show_always = false;
        };

        hostname = {
          format = "[$hostname]($style) ";
          style = "bold lavender";
          ssh_only = true;
        };

        status = {
          disabled = false;
          format = "[$symbol$status]($style) ";
          symbol = "✘ ";
          style = "bold red";
        };

        cmd_duration = {
          min_time = 2000;
          format = "[󱑆 $duration]($style) ";
          style = "bold yellow";
        };

        jobs = {
          format = "[$symbol$number]($style) ";
          symbol = "󰜎 ";
          style = "bold blue";
        };

        time = {
          disabled = false;
          format = "[$time]($style)";
          style = "subtext0";
          time_format = "%H:%M";
        };
      };
    };
  };
}
