# Neovim Configuration Analysis

## Project Overview

This directory contains a comprehensive Neovim configuration, primarily written in Lua. It is structured to be modular and easily maintainable. The configuration uses `lazy.nvim` for plugin management, which automatically installs and loads plugins as needed.

The setup is heavily focused on providing a modern, IDE-like experience directly in the terminal, with a strong emphasis on LSP (Language Server Protocol) integration for features like autocompletion, diagnostics, and code navigation.

**Key Technologies & Features:**

*   **Language:** Lua
*   **Plugin Manager:** `lazy.nvim`
*   **Core Components:**
    *   **LSP:** `nvim-lspconfig` for managing language servers.
    *   **LSP Installer:** `mason.nvim` and `mason-lspconfig.nvim` for automatically installing and managing LSPs and other tools.
    *   **Completions:** `nvim-cmp` for a rich autocompletion experience.
    *   **Formatting:** `conform.nvim` for automatic code formatting on save.
    *   **Linting:** `nvim-lint` for running linters and displaying diagnostics.
*   **UI:** The UI is customized with plugins like `lualine.nvim` for the statusline and `nvim-tree.lua` for a file explorer.
*   **Keymappings:** A comprehensive set of keymappings is defined in `lua/mappings.lua`, with `<Space>` as the leader key.

## Building and Running

This is a Neovim configuration, so there is no traditional "build" step.

*   **Running:** To "run" this project, simply open Neovim. The configuration will be loaded automatically.
*   **Plugin Installation:** The first time you open Neovim, `lazy.nvim` will automatically install all the configured plugins. You can also manage plugins with the `:Lazy` command.
*   **Tool Installation:** `mason.nvim` will install the configured LSPs and other tools. You can manage these with the `:Mason` command.

## Development Conventions

*   **File Structure:** The configuration is organized into several directories:
    *   `init.lua`: The main entry point of the configuration.
    *   `lua/`: Contains the core Lua modules.
        *   `lua/options.lua`: Sets Neovim's options.
        *   `lua/plugins.lua`: Defines the list of plugins to be installed by `lazy.nvim`.
        *   `lua/mappings.lua`: Contains global keymappings.
        *   `lua/autocmd.lua`: Contains autocommands.
        *   `lua/plugins/`: Contains the configuration for individual plugins.
        *   `lua/snippets/`: Contains custom code snippets.
    *   `ftplugin/`: Contains filetype-specific plugin configurations.
*   **Plugin Configuration:** Each plugin is configured in its own file under `lua/plugins/`. This keeps the configuration modular and easy to manage.
*   **Keymapping:** A helper function `KeymapOptions` is used to create keymappings with a description, which is then used by `which-key.nvim` to display available keybindings.
*   **LSP and Tools:** The configuration clearly separates the concerns of LSP, formatting, and linting.
    *   LSP servers are configured in `lua/plugins/lsp.lua`.
    *   Formatters are configured in `lua/plugins/conform.lua`.
    *   Linters are configured in `lua/plugins/nvim-lint.lua`.
