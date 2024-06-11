-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local opts = { noremap = true }

-- remap escape key to control-j
map("i", "<C-j>", "<esc>", opts)

-- replace semicolon with colon
map("n", ";", ":", {})

-- curson to beginning, end of line on H or L
map("n", "H", "^", {})
map("n", "L", "$", {})
