-- Neovim config — intentionally minimal.
--
-- This is a dependency-free, offline-safe baseline: no plugin manager, no
-- external plugins, just sensible built-in options and a handful of keymaps.
-- Grow it by adding a plugin manager (e.g. lazy.nvim) and splitting config into
-- lua/ modules — but keep this file working on a bare machine with no network.

-- Leader must be set before any mapping that uses it.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- Line numbers.
opt.number = true
opt.relativenumber = true

-- Indentation.
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

-- Searching: case-insensitive unless the query has a capital.
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Appearance.
opt.termguicolors = true
opt.scrolloff = 8

-- Integration + persistence.
opt.clipboard = "unnamedplus"
opt.undofile = true

-- Keymaps.
local map = vim.keymap.set

-- Save / quit.
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })

map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Easier window navigation.
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
