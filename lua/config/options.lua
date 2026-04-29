-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local is_wsl = false
local is_mac = vim.fn.has("mac") == 1
local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local is_linux = vim.fn.has("unix") == 1 and not is_mac and not is_windows

if is_linux then
  local handle = io.popen("uname -r 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    result = result and result:lower()
    if result and (result:find("microsoft") or result:find("wsl")) then
      is_wsl = true
    end
  end
end

local function split_clipboard_text(text)
  text = (text or ""):gsub("\r\n", "\n"):gsub("\r", "\n")
  if text:sub(-1) == "\n" then
    text = text:sub(1, -2)
  end
  return vim.split(text, "\n", { plain = true }), "v"
end

local powershell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
local powershell_copy = table.concat({
  "$stream = [Console]::OpenStandardInput()",
  "$buffer = [byte[]]::new(4096)",
  "$memory = [System.IO.MemoryStream]::new()",
  "while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) { $memory.Write($buffer, 0, $read) }",
  "$text = [System.Text.Encoding]::UTF8.GetString($memory.ToArray())",
  "Set-Clipboard -Value $text",
}, "; ")
local powershell_paste = table.concat({
  "[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)",
  "$text = Get-Clipboard -Raw",
  "if ($null -ne $text) { [Console]::Out.Write($text) }",
}, "; ")

local function windows_copy(lines, _)
  vim.system({ powershell, "-NoLogo", "-NoProfile", "-Command", powershell_copy }, {
    stdin = table.concat(lines, "\n"),
    text = true,
  }):wait()
end

local function windows_paste()
  local result = vim.system({ powershell, "-NoLogo", "-NoProfile", "-Command", powershell_paste }, {
    text = true,
  }):wait()
  return split_clipboard_text(result.stdout)
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
    name = "Windows PowerShell Clipboard",
    copy = {
      ["+"] = windows_copy,
      ["*"] = windows_copy,
    },
    paste = {
      ["+"] = windows_paste,
      ["*"] = windows_paste,
    },
    cache_enabled = 0,
  }
elseif is_mac then
  vim.g.clipboard = {
    name = "mac",
    copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
    paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
  }
elseif vim.env.WAYLAND_DISPLAY and vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1 then
  vim.g.clipboard = {
    name = "wayland",
    copy = { ["+"] = "wl-copy", ["*"] = "wl-copy --primary" },
    paste = { ["+"] = "wl-paste --no-newline", ["*"] = "wl-paste --primary --no-newline" },
    cache_enabled = 0,
  }
elseif vim.fn.executable("xclip") == 1 then
  vim.g.clipboard = {
    name = "xclip",
    copy = { ["+"] = "xclip -selection clipboard", ["*"] = "xclip -selection primary" },
    paste = { ["+"] = "xclip -selection clipboard -o", ["*"] = "xclip -selection primary -o" },
    cache_enabled = 0,
  }
elseif vim.fn.executable("xsel") == 1 then
  vim.g.clipboard = {
    name = "xsel",
    copy = { ["+"] = "xsel --clipboard --input", ["*"] = "xsel --primary --input" },
    paste = { ["+"] = "xsel --clipboard --output", ["*"] = "xsel --primary --output" },
    cache_enabled = 0,
  }
else
  vim.opt.clipboard = "unnamedplus"
end
