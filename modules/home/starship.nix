{ ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      add_newline = false;
      format = "$os$directory$git_branch$git_status$cmd_duration$character";
      right_format = "";

      character = {
        success_symbol = "[❯](bold green) ";
        error_symbol = "[❯](bold red) ";
        vimcmd_symbol = "[❮](bold yellow) ";
      };

      os = {
        disabled = false;
        format = "[ $symbol ](bold fg:#111111 bg:#ffffff)";
        symbols = {
          NixOS = "";
          Arch = "";
        };
      };

      directory = {
        disabled = false;
        truncation_length = 3;
        truncate_to_repo = true;
        home_symbol = "~";
        format = "[](fg:#ffffff bg:#3daee9)[  $path ](bold fg:#ffffff bg:#3daee9)[](fg:#3daee9)";
      };

      git_branch = {
        symbol = " ";
        format = "[ $symbol$branch ](bold fg:#111111 bg:#39d353)[](fg:#39d353)";
      };

      git_status = {
        disabled = false;
        format = "[$all_status$ahead_behind](bold fg:#111111 bg:#39d353)[](fg:#39d353)";
        conflicted = "=";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "?\${count}";
        stashed = "$\${count}";
        modified = "!\${count}";
        staged = "+\${count}";
        renamed = "»\${count}";
        deleted = "✘\${count}";
      };

      cmd_duration = {
        min_time = 500;
        show_milliseconds = false;
        format = "[ took \${duration}](dimmed)";
      };

      username.disabled = true;
      hostname.disabled = true;
      localip.disabled = true;
      jobs.disabled = true;
      battery.disabled = true;
      time.disabled = true;
      package.disabled = true;
      shell.disabled = true;
      memory_usage.disabled = true;
      python.disabled = true;
      nodejs.disabled = true;
      rust.disabled = true;
      golang.disabled = true;
      java.disabled = true;
      lua.disabled = true;
      docker_context.disabled = true;
      nix_shell.disabled = true;
      conda.disabled = true;
      status.disabled = true;
      sudo.disabled = true;
      container.disabled = true;
      line_break.disabled = true;
    };
  };
}