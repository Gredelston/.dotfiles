---@type MappingsConfig
local M = {}

M.general = {
  n = {
    [";"] = {":", "enter command mode", opts = { nowait = true } },
    [":"] = {";", "Repeat latest f, t, F, or T [count] times. See cpo-;"},
    ["<C-f>"] = {":Telescope fd<CR>", "Open file fuzzy-finder"},
  },
  i = {
    ["jk"] = {"<ESC>", "Exit insert mode."},
  }
}

return M
