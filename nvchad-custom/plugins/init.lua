---@type {[PluginName]: NvPluginConfig|false}
local plugins = {
  -- Override plugin definition options
  ["NvChad/ui"] = {
    override_options = {
      tabufline = {
        lazyload = false, -- to show tabufline by default
      }
    }
  }
}

return plugins
