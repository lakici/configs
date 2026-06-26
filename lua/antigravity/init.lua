local M = {}

-- Helper to check if a binary is in PATH
local function has_binary(bin)
  return vim.fn.executable(bin) == 1
end

function M.setup(opts)
  opts = opts or {}
  local binary = opts.binary or "agy"
  local split_side = opts.split_side or "right"
  local split_width_percentage = opts.split_width_percentage or 0.30

  if not has_binary(binary) then
    vim.notify("Antigravity: '" .. binary .. "' not found in PATH", vim.log.levels.WARN)
  end

  -- Create user commands
  vim.api.nvim_create_user_command("Antigravity", function(cmd_opts)
    local args = cmd_opts.args ~= "" and (" " .. cmd_opts.args) or ""
    local cmd = binary .. args
    
    -- Check if snacks.nvim is loaded and use it, otherwise fallback to default terminal split
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.terminal then
      -- Toggle the terminal with the specified command
      snacks.terminal.toggle(cmd, {
        win = {
          position = split_side,
          width = split_width_percentage,
        }
      })
    else
      local width = math.floor(vim.o.columns * split_width_percentage)
      local placement = split_side == "left" and "topleft " or "botright "
      vim.cmd(placement .. width .. "vsplit")
      vim.cmd("terminal " .. cmd)
      vim.cmd("startinsert")
    end
  end, { nargs = "*" })

  vim.api.nvim_create_user_command("AntigravityContinue", function()
    vim.cmd("Antigravity --continue")
  end, {})

  vim.api.nvim_create_user_command("AntigravityNew", function()
    vim.cmd("Antigravity --new-project")
  end, {})
end

return M
