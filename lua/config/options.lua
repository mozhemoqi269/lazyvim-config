-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local is_wsl = false
local is_mac = vim.fn.has("mac") == 1
local is_windows = vim.fn.has("win64") == 1
local is_linux = vim.fn.has("unix") == 1 and not is_mac and not is_windows

if is_linux then
  local handle = io.popen("uname -r 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    if result and (result:find("microsoft") or result:find("WSL")) then
      is_wsl = true
    end
  end
end

if is_wsl then
  vim.g.clipboard = {
    name = "WSL+win32yank",
    copy = { ["+"] = "win32yank.exe -i --crlf", ["*"] = "win32yank.exe -i --crlf" },
    paste = { ["+"] = "win32yank.exe -o --lf", ["*"] = "win32yank.exe -o --lf" },
    cache_enabled = 0,
  }
elseif is_windows then
  vim.g.clipboard = {
    name = "native",
    copy = { ["+"] = "clip.exe", ["*"] = "clip.exe" },
    paste = { ["+"] = "powershell -command \"Get-Clipboard -Raw\"", ["*"] = "powershell -command \"Get-Clipboard -Raw\"" },
  }
elseif is_mac then
  vim.g.clipboard = {
    name = "mac",
    copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
    paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
  }
else
  vim.g.clipboard = {
    name = "linux",
    copy = { ["+"] = "xclip -selection clipboard", ["*"] = "xclip -selection clipboard" },
    paste = { ["+"] = "xclip -selection clipboard -o", ["*"] = "xclip -selection clipboard -o" },
  }
end