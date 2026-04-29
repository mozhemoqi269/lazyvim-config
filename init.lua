-- bootstrap lazy.nvim, LazyVim and your plugins
vim.env.WIN32YANK_EXECUTABLE = ""
require("config.lazy")
vim.opt.clipboard = "unnamedplus"