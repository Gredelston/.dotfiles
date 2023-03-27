vim.api.nvim_create_autocmd(
  { "BufNewFile", "BufRead" }, {
    pattern = "*.star",
    command = "set syntax=python",
  }
)

vim.opt.termguicolors = true
