local router = require 'pointer.lib.router'

local M = {}

--- Set up keybindings for the sidepanel
--- @param buf number The buffer ID to set keybindings for
function M.setup(buf)
  -- Ensure buffer is properly configured for keybindings
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'pointer-sidepanel')
  
  -- Help view keybindings
  vim.api.nvim_buf_set_keymap(buf, 'n', '?', '', {
    callback = function()
      router.navigate('help')
    end,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '', {
    callback = function()
      local current_view = router.get_current_view()
      if current_view and current_view.name == 'help' then
        router.navigate('chat')
      end
    end,
    noremap = true,
    silent = true,
  })
end

return M 