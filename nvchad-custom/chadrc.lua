-- First read our docs (completely) then check the example_config repo
-- https://github.com/NvChad/example_config

local M = {}

M.ui = {
  theme_toggle = { "chadracula", "dark_horizon"},
  theme = "chadracula",
  nvdash = {
    load_on_startup = true,
  }
}

M.mappings = require "custom.mappings"
M.plugins = "custom.plugins"

return M
