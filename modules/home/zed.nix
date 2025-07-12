{ pkgs, ... }:
{
  home.packages = with pkgs; [
    zed-editor
    # Formatters for external formatting
    prettierd
    # LSP servers
    rust-analyzer
    nil
    typescript-language-server
    nodePackages.prettier
  ];

  # Zed configuration
  xdg.configFile."zed/settings.json".text = builtins.toJSON {
    # Context servers for AI integration
    context_servers = {
      mcp-server-figma = {
        settings = {
        };
      };
    };

    # Agent settings for AI
    agent = {
      default_model = {
        provider = "zed.dev";
        model = "claude-sonnet-4";
      };
      model_parameters = [ ];
      always_allow_tool_actions = true;
      version = "2";
      preferred_completion_mode = "burn";
    };

    # UI and font settings
    ui_font_size = 15;
    buffer_font_size = 14;
    # Theme and fonts will be handled by Stylix
    theme = {
      mode = "system";
      dark = "Gruvbox Dark"; # Fallback theme
    };

    # Vim mode
    vim_mode = true;

    # Format settings
    format_on_save = "on";
    soft_wrap = "preferred_line_length";
    preferred_line_length = 80;

    # Language-specific settings
    languages = {
      JavaScript = {
        format_on_save = {
          external = {
            command = "prettierd";
            arguments = [
              "--stdin-filepath"
              "{buffer_path}"
            ];
          };
        };
      };
      TypeScript = {
        tab_size = 2;
        hard_tabs = false;
        format_on_save = {
          external = {
            command = "prettierd";
            arguments = [
              "--stdin-filepath"
              "{buffer_path}"
            ];
          };
        };
      };
      PHP = {
        format_on_save = {
          external = {
            command = "prettierd";
            arguments = [
              "--stdin-filepath"
              "{buffer_path}"
            ];
          };
        };
      };
      CSS = {
        format_on_save = {
          external = {
            command = "prettierd";
            arguments = [
              "--stdin-filepath"
              "{buffer_path}"
            ];
          };
        };
      };
      JSON = {
        tab_size = 2;
        hard_tabs = false;
        format_on_save = {
          external = {
            command = "prettierd";
            arguments = [
              "--stdin-filepath"
              "{buffer_path}"
            ];
          };
        };
      };
      # Additional language configurations
      Nix = {
        tab_size = 2;
        hard_tabs = false;
        format_on_save = "language_server";
      };
      Rust = {
        tab_size = 4;
        hard_tabs = false;
        format_on_save = "language_server";
      };
    };

    # Editor settings
    tab_size = 2;
    hard_tabs = false;
    show_whitespaces = "selection";
    remove_trailing_whitespace_on_save = true;
    ensure_final_newline_on_save = true;

    # UI settings
    toolbar = {
      breadcrumbs = true;
      quick_actions = true;
    };

    scrollbar = {
      show = "auto";
      git_diff = true;
      search_results = true;
      selected_symbol = true;
      diagnostics = true;
    };

    # Git settings
    git = {
      git_gutter = "tracked_files";
      inline_blame = {
        enabled = true;
        delay_ms = 600;
      };
    };

    # Terminal settings
    terminal = {
      shell = "zsh";
      working_directory = "current_project_directory";
      blinking = "terminal_controlled";
      alternate_scroll = "off";
      option_as_meta = false;
    };

    # LSP settings
    lsp = {
      "rust-analyzer" = {
        binary = {
          path = "${pkgs.rust-analyzer}/bin/rust-analyzer";
        };
      };
      "nil" = {
        binary = {
          path = "${pkgs.nil}/bin/nil";
        };
      };
    };

    # Auto-update
    auto_update = false;

    # Telemetry
    telemetry = {
      metrics = false;
      diagnostics = false;
    };
  };

  # Zed keymap configuration
  xdg.configFile."zed/keymap.json".text = builtins.toJSON [
    {
      context = "Workspace";
      bindings = {
        # "shift shift" = "file_finder::Toggle";  # Commented out in original
      };
    }
    {
      context = "Editor";
      bindings = {
        # "j k" = ["workspace::SendKeystrokes" "escape"];  # Commented out in original
      };
    }
    {
      context = "Editor && vim_mode == normal && vim_operator == none && !VimWaiting";
      bindings = {
        "space space" = "file_finder::Toggle";
        "space s g" = "workspace::NewSearch";
        "space e" = "workspace::ToggleLeftDock";
        "space t" = "workspace::ToggleBottomDock";
        "space g g" = "git::Commit";
        "space g p" = "git::Push";
        "space g c" = "git::Commit";
        "space g b" = "git::Blame";
        "space b r" = "pane::CloseItemsToTheRight";
        "space b l" = "pane::CloseItemsToTheLeft";
        "space s r" = "search::ToggleReplace";
        "space /" = [
          "editor::ToggleComments"
          {
            advance_downwards = false;
          }
        ];
      };
    }
    {
      context = "ProjectPanel && not_editing";
      bindings = {
        "h" = "project_panel::CollapseSelectedEntry";
        "l" = "project_panel::ExpandSelectedEntry";
        "j" = "menu::SelectNext";
        "k" = "vim::SelectPrevious";
        "o" = "menu::Confirm";
        "r" = "project_panel::Rename";
        "z c" = "project_panel::CollapseSelectedEntry";
        "z o" = "project_panel::ExpandSelectedEntry";
        "shift-o" = "project_panel::RevealInFileManager";
        "x" = "project_panel::Cut";
        "c" = "project_panel::Copy";
        "p" = "project_panel::Paste";
        "d" = "project_panel::Delete";
        "a" = "project_panel::NewFile";
        "shift-a" = "project_panel::NewDirectory";
        "shift-y" = "workspace::CopyRelativePath";
        "g y" = "workspace::CopyPath";
      };
    }
    {
      context = "ProjectPanel";
      bindings = {
        "escape" = "workspace::ToggleLeftDock";
      };
    }
    {
      context = "Terminal";
      bindings = {
        "cmd-n" = "workspace::NewTerminal";
        "cmd-d" = "pane::CloseActiveItem";
        "cmd-t" = "workspace::ToggleBottomDock";
        "cmd-shift-f" = "workspace::ToggleZoom";
        "escape" = "workspace::ToggleBottomDock";
      };
    }
  ];
}
