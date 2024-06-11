-- Adapted from the example.lua spec.

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
  -- add gruvbox
  -- { "ellisonleao/gruvbox.nvim" },

  {
    "mhinz/vim-startify",
  },

  {
    "oxfist/night-owl.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("night-owl").setup()
      vim.cmd.colorscheme("night-owl")
    end,
  },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "night-owl",
    },
  },

  -- change trouble config
  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    opts = { use_diagnostic_signs = true },
  },

  -- disable trouble
  { "folke/trouble.nvim", enabled = true },

  -- override nvim-cmp and add cmp-emoji
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji" })
    end,
  },

  -- Better GREP
  {
    "BurntSushi/ripgrep",
  },

  -- Better file find
  {
    "sharkdp/fd",
  },

  -- Fuzzy find searching
  {
    "junegunn/fzf",
  },

  {
    "junegunn/fzf.vim",
  },

  -- change some telescope options and a keymap to browse plugin files
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      {
        "<leader>fp",
        function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
        desc = "Find Plugin File",
      },
      requires = { "nvim-lua/plenary.nvim" },
    },
    -- change some options
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
      },
    },
  },

  -- add pyright to lspconfig
  -- modified to include rust_analyzer
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        pyright = {},
        rust_analyzer = {},
      },
      rust_analyzer = function(_, opts)
        require("lazyvim.util").on_attach(function(client, buffer)
          -- stylua: ignore
          if client.name == "rust_analyzer" then
            vim.keymap.set("n", "K", "<cmd>RustHoverActions<cr>", { buffer = buffer, desc = "Hover Actions (Rust)" })
            vim.keymap.set("n", "<leader>cR", "<cmd>RustCodeAction<cr>", { buffer = buffer, desc = "Code Action (Rust)" })
            vim.keymap.set("n", "<leader>dr", "<cmd>RustDebuggables<cr>", { buffer = buffer, desc = "Run Debuggables (Rust)" })
          end
        end)
        local mason_registry = require("mason-registry")
        -- rust tools configuration for debugging support
        local codelldb = mason_registry.get_package("codelldb")
        local extension_path = codelldb:get_install_path() .. "/extension/"
        local codelldb_path = extension_path .. "adapter/codelldb"
        local liblldb_path = vim.fn.has("mac") == 1 and extension_path .. "lldb/lib/liblldb.dylib"
          or extension_path .. "lldb/lib/liblldb.so"
        local rust_tools_opts = vim.tbl_deep_extend("force", opts, {
          dap = {
            adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
          },
          tools = {
            on_initialized = function()
              vim.cmd([[
              augroup RustLSP
              autocmd CursorHold                      *.rs silent! lua vim.lsp.buf.document_highlight()
              autocmd CursorMoved,InsertEnter         *.rs silent! lua vim.lsp.buf.clear_references()
              autocmd BufEnter,CursorHold,InsertLeave *.rs silent! lua vim.lsp.codelens.refresh()
              augroup END
              ]])
            end,
          },
          server = {
            settings = {
              ["rust-analyzer"] = {
                cargo = {
                  allFeatures = true,
                  loadOutDirsFromCheck = true,
                  runBuildScripts = true,
                },
                -- Add clippy lints for Rust.
                checkOnSave = {
                  allFeatures = true,
                  command = "clippy",
                  extraArgs = { "--no-deps" },
                },
                procMacro = {
                  enable = true,
                  ignored = {
                    ["async-trait"] = { "async_trait" },
                    ["napi-derive"] = { "napi" },
                    ["async-recursion"] = { "async_recursion" },
                  },
                },
              },
            },
          },
        })
        require("rust-tools").setup(rust_tools_opts)
        return true
      end,
      taplo = function(_, _)
        local function show_documentation()
          if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
            require("crates").show_popup()
          else
            vim.lsp.buf.hover()
          end
        end
        require("lazyvim.util").on_attach(function(client, buffer)
          -- stylua: ignore
          if client.name == "taplo" then
            vim.keymap.set("n", "K", show_documentation, { buffer = buffer, desc = "Show Crate Documentation" })
          end
        end)
        return false -- make sure the base implementation calls taplo.setup
      end,
    },
  },

  -- add more treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      },
      auto_install = true,
      highlight = { enable = true },
      incremental_selection = { enable = true },
      textobjects = { enable = true },
    },
  },

  {
    "tpope/vim-surround",
  },

  -- use mini.starter instead of alpha
  { import = "lazyvim.plugins.extras.ui.mini-starter" },

  -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
  { import = "lazyvim.plugins.extras.lang.json" },

  -- add any tools you want to have installed below
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "codelldb",
        "rust-analyzer",
        "taplo",
        "prettier",
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
      },
    },
  },

  -- Use <tab> for completion and snippets (supertab)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif vim.snippet.active({ direction = 1 }) then
            vim.schedule(function()
              vim.snippet.jump(1)
            end)
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif vim.snippet.active({ direction = -1 }) then
            vim.schedule(function()
              vim.snippet.jump(-1)
            end)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
}
