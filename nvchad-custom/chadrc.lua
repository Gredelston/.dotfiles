-- First read our docs (completely) then check the example_config repo
-- https://github.com/NvChad/example_config

local M = {}

M.ui = {
  theme_toggle = { "chadracula", "dark_horizon"},
  theme = "dark_horizon",
}

M.mappings = require "custom.mappings"
M.plugins = require "custom.plugins"

return M
