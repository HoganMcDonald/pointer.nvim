--- Theme utilities for pointer.nvim UI components
local M = {}

-- Common highlight groups that represent accent colors in various themes
local accent_highlight_groups = {
  -- Popular modern themes
  'TSString', -- TreeSitter string color (often an accent color)
  '@function', -- TreeSitter function color
  'Function', -- Function color

  -- Theme-specific accent colors
  'CursorLineNr', -- Often a theme accent color
  'Question', -- Often a theme accent color
  'MoreMsg', -- Often a theme accent color
  'Title', -- Titles are often in accent colors
  'Identifier', -- Often a good accent color
  'Directory', -- Directory color is often an accent
  'SpecialKey', -- Special keys are often in accent colors

  -- Default to Statement for bright color
  'Statement', -- Statement color (fallback)
  'Special', -- Special color (fallback)
}

--- Initializes UI theme highlights
function M.setup_highlights()
  -- Find the first available accent highlight group
  local accent_group = 'Special' -- Default fallback

  for _, group in ipairs(accent_highlight_groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
    if ok and next(hl) and (hl.fg or hl.foreground) then
      accent_group = group
      break
    end
  end

  -- Create our highlight groups
  vim.api.nvim_set_hl(0, 'PointerUIHeader', { link = accent_group })
  vim.api.nvim_set_hl(0, 'PointerUITitle', { link = accent_group, bold = true })
  vim.api.nvim_set_hl(0, 'PointerUILabel', { link = 'Label' })
  vim.api.nvim_set_hl(0, 'PointerUIText', { link = 'Normal' })
  vim.api.nvim_set_hl(0, 'PointerUIBorder', { link = 'VertSplit' }) -- Use split line color
end

-- Update highlights when colorscheme changes
function M.setup_theme_autocmds()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = 'PointerSidepanel',
    callback = function()
      M.setup_highlights()
    end,
  })
end

return M
