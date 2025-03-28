-- Prevent loading this plugin multiple times
if vim.g.loaded_pointer == 1 then
  return
end
vim.g.loaded_pointer = 1

-- Plugin commands
vim.api.nvim_create_user_command('PointerEnable', function()
  -- Command implementation
end, {})

vim.api.nvim_create_user_command('PointerDisable', function()
  -- Command implementation
end, {})

-- You could also set up any global keymappings here
