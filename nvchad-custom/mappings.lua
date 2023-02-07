---@type MappingsConfig
local M = {}

M.general = {
  n = {
    [";"] = {":", "enter command mode", opts = { nowait = true } },
    [":"] = {";", "Repeat latest f, t, F, or T [count] times. See cpo-;"},
  },
  i = {
    ["jk"] = {"<ESC>", "Exit insert mode."},
  }
}

return M
