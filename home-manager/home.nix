{ username, config, guiEnabled ? true, ... }:
{
  home-manager = {
    backupFileExtension = "bkup";
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${username} =
      {
        inputs,
        pkgs,
        config,
        lib,
        ...
      }:
      {
        home.stateVersion = "25.11";

        home.file.".p10k.zsh".source = ./p10k.zsh;

        # Additional Packages
        home.packages = with pkgs; [
          bun
          deno
          go
          act # GitHub Actions Toolkit
          mise
          lazygit
          ripgrep
          uv
          lazydocker
          fd
          zoxide
          fzf
          tree
          tldr
          diff-so-fancy
          nixfmt
          nh
          nix-output-monitor
        ] ++ lib.optionals guiEnabled [
          # GUI Editors
          code-cursor
          vscode
          discord
        ];

        home.sessionVariables = lib.mkMerge [
          {
            EDITOR = if guiEnabled then "code --wait" else "vim";
          }
          (lib.mkIf guiEnabled {
            BROWSER = "google-chrome";
            TERMINAL = "ghostty";
          })
        ];

        programs.eza = {
          enable = true;
          enableZshIntegration = true;
          enableBashIntegration = true;
          extraOptions = [
            "--icons"
            "--git"
          ];
        };

        programs.ghostty = lib.mkIf guiEnabled {
          enable = true;
          # Only install the package on Linux; on macOS it's installed via Homebrew
          package = if pkgs.stdenv.isLinux then pkgs.ghostty else null;
          enableZshIntegration = true;
          settings = {
            theme = "Catppuccin Frappe";
            font-family = "Monaspace Argon";
            font-size = 10;
            background-opacity = 0.95;
            background-blur = "true";
            window-padding-x = 10;
            window-padding-y = 4;
            window-width = 102;
            window-height = 30;
          };
        };

        programs.bat = {
          enable = true;
          config = {
            pager = "less -FR";
          };
          extraPackages = with pkgs.bat-extras; [
            batman
            batpipe
            batgrep
          ];
        };

        # Git Configuration
        programs.git = {
          enable = true;

          settings = {
            user = {
              name = "Maciej Garncarski";
              email = "maciejgarncarski@protonmail.com";
            };
          };
        };

        # Zsh Configuration
        programs.zsh = {
          enable = true;
          enableCompletion = true;
          syntaxHighlighting.enable = true;
          autosuggestion.enable = true;

          plugins = [
            {
              name = "powerlevel10k";
              src = pkgs.zsh-powerlevel10k;
              file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
            }
          ];

          initContent = lib.mkMerge [
            (lib.mkBefore ''
              [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
            '')
            (lib.mkAfter ''
              eval "$(${pkgs.mise}/bin/mise activate zsh)"
              bindkey '^[[1;5D' backward-word
              bindkey '^[[1;5C' forward-word
            '')
          ];

          shellAliases = {
            ls = "eza";
            cat = "bat";
            lg = "lazygit";

            # Git
            gdc = "git diff --cached";
            gdom = "git diff origin/main";
            glog = "git log --oneline";
            gs = "git status";
            gadd = "git add .";

            pi = "pnpm install";
            padd = "pnpm add";

            # Docker
            doco = "docker compose";
          };
        };
      };
  };

}
