{
  inputs,
  config,
  pkgs,
  ...
}:

{
  imports = [
    inputs.nix4nvchad.homeManagerModule
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "blakeh";
  home.homeDirectory = "/home/b/bl/blakeh";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    #".ssh".source = "${toString config.home.homeDirectory}/remote/.ssh";
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jaysa/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Let Home Manager install and manage itself.

  #systemwide dark mode, including firefox
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk.font.size = 32;

  programs = {
    nvchad.enable = true;
    firefox = {
      enable = true;
      policies = {
        # got this from https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        #	ExtensionSettings = {
        #	 "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
        #         # uBlock Origin:
        #          "uBlock0@raymondhill.net" = {
        #            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        #            installation_mode = "force_installed";
        #          };
        #	  "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
        #	    install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        #	    installation_mode = "force_installed";
        #	  };
        #	};
      };
      profiles = {
        "blakeh" = {
          id = 0;
          isDefault = true;

          search.engines = {
            "Nix Packages" = {
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };
            "Nix Options" = {
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@no" ];
              urls = [
                {
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };
            "Home Manager Options" = {
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@hm" ];
              urls = [
                {
                  template = "https://home-manager-options.extranix.com/";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };
          };

          settings = {
            "browser.startup.homepage" =
              "http://printhost.ocf.berkeley.edu/jobs/|http://logjam/|http://papercut/|http://pagefault/|http://169.229.226.96";
          };

          extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
            ublock-origin
            bitwarden
            darkreader
            #gruvbox-dark-theme
          ];

          extraConfig = ''
            	   user_pref("extensions.autoDisableScopes", 0);
            	   user_pref("extensions.enabledScopes", 15);
            	 '';

        };
      };
    };
    git = {
      enable = true;
      settings = {
        user = {
          name = "Blake Haug";
          email = "blake@blakehaug.com";
        };
        commit.gpgsign = true;
        gpg.format = "ssh";
        gpg.ssh.allowedsignersfile = "${toString config.home.homeDirectory}/.ssh/allowed_signers";
        user.signingkey = "${toString config.home.homeDirectory}/.ssh/id_ed25519_sk.pub";
        init.defaultbranch = "main";
      };
    };
    neovim = {
      enable = false;
      defaultEditor = true;
      extraConfig = ''
                set background=dark
        	colorscheme gruvbox
        	set number
      '';
      plugins = with pkgs.vimPlugins; [
        gruvbox
        #everforest
        neo-tree-nvim
        nvim-web-devicons # neotree optional
        nvim-window-picker # neotree optional
        plenary-nvim # neotree dependency
        nui-nvim # neotree dependency
        nvim-treesitter
        nvim-treesitter-parsers.yaml
        nvim-treesitter-parsers.rust
        nvim-treesitter-parsers.python
        nvim-treesitter-parsers.puppet
        nvim-treesitter-parsers.nix
        nvim-treesitter-parsers.javascript
        nvim-treesitter-parsers.java
        nvim-treesitter-parsers.c
        nvim-treesitter-parsers.markdown
        nvim-treesitter-parsers.markdown_inline
        nvim-treesitter-parsers.markdown_inline
        nvim-treesitter-parsers.html
        nvim-treesitter-parsers.css
      ];
      viAlias = true;
      vimAlias = true;
    };
    starship = {
      enable = true;
    };
    kitty = {
      enable = true;
      enableGitIntegration = true;

      #https://github.com/kovidgoyal/kitty-themes/tree/master/themes for more themes
      #themeFile = "everforest_dark_medium";
      themeFile = "gruvbox-dark-hard";

      font = {
        name = "hack";
        #size = 20.0;
      };
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "/home/b/bl/blakeh/remote/hyprland-home-manager/night_sky-Blake_Haug.png"
      ];
      wallpaper = [
        ", /home/b/bl/blakeh/remote/hyprland-home-manager/night_sky-Blake_Haug.png"
      ];
    };
  };
}
