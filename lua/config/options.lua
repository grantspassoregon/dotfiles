-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.mouse = "a" --enable mouse use in all modes

-- Filetypes
opt.encoding = "utf8"
opt.fileencoding = "utf8"

local g = vim.g

-- Rust
g.rustfmt_autosave = 1
g.rustfmt_emit_files = 1
g.rustfmt_fail_silently = 0
