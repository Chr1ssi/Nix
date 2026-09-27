local M = {}

function M.setup()
  local fallback = {
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
  }
  local state_home = vim.env.XDG_STATE_HOME or (vim.env.HOME .. '/.local/state')
  local generated = loadfile(state_home .. '/mywm/nvim.lua')
  local palette = generated and generated() or fallback
  require('base16-colorscheme').setup(palette)

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = palette.base05, bg = palette.base00 })
  hi('TelescopeBorder',         { fg = palette.base03, bg = palette.base00 })
  hi('TelescopePromptNormal',   { fg = palette.base05, bg = palette.base00 })
  hi('TelescopePromptBorder',   { fg = palette.base03, bg = palette.base00 })
  hi('TelescopePromptPrefix',   { fg = palette.base0D, bg = palette.base00 })
  hi('TelescopePromptCounter',  { fg = palette.base04, bg = palette.base00 })
  hi('TelescopePromptTitle',    { fg = palette.base00, bg = palette.base0D })
  hi('TelescopePreviewTitle',   { fg = palette.base00, bg = palette.base0A })
  hi('TelescopeResultsTitle',   { fg = palette.base00, bg = palette.base0E })
  hi('TelescopeSelection',      { fg = palette.base05, bg = palette.base02 })
  hi('TelescopeSelectionCaret', { fg = palette.base0D, bg = palette.base02 })
  hi('TelescopeMatching',       { fg = palette.base0D, bold = true })
end

-- Register a signal handler for SIGUSR1 (mywm theme updates).
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
