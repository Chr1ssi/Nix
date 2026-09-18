 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#000000',
    base01 = '#111415',
    base02 = '#1a1d20',
    base03 = '#8a9298',
    base04 = '#c0c7cf',
    base05 = '#e1e2e6',
    base06 = '#e1e2e6',
    base07 = '#e1e2e6',
    base08 = '#ffb4ab',
    base09 = '#e6b6f3',
    base0A = '#b3c9db',
    base0B = '#91cef7',
    base0C = '#e6b6f3',
    base0D = '#91cef7',
    base0E = '#b3c9db',
    base0F = '#cfe5f8',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e1e2e6',          bg = '#000000' })
  hi('TelescopeBorder',         { fg = '#8a9298',             bg = '#000000' })
  hi('TelescopePromptNormal',   { fg = '#e1e2e6',          bg = '#000000' })
  hi('TelescopePromptBorder',   { fg = '#8a9298',             bg = '#000000' })
  hi('TelescopePromptPrefix',   { fg = '#91cef7',             bg = '#000000' })
  hi('TelescopePromptCounter',  { fg = '#c0c7cf',  bg = '#000000' })
  hi('TelescopePromptTitle',    { fg = '#000000',             bg = '#91cef7' })
  hi('TelescopePreviewTitle',   { fg = '#000000',             bg = '#b3c9db' })
  hi('TelescopeResultsTitle',   { fg = '#000000',             bg = '#e6b6f3' })
  hi('TelescopeSelection',      { fg = '#e1e2e6',          bg = '#1a1d20' })
  hi('TelescopeSelectionCaret', { fg = '#91cef7',             bg = '#1a1d20' })
  hi('TelescopeMatching',       { fg = '#91cef7',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
