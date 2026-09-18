-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- German QWERTZ ergonomics: keep Vim's commands, but move two awkward symbols
-- to the umlaut keys next to the home row.
vim.keymap.set({ "n", "x" }, "ö", ":", { desc = "Befehlszeile" })
vim.keymap.set({ "n", "x", "o" }, "ä", ";", { desc = "Nächstes f/t-Ziel" })
