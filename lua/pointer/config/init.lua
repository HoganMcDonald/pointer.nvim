local M = {}
local schema = require("pointer.lib.schema")

-- Define schema for PointerOptions
local optionsSchema = schema.object({
  width = schema.number(),
  position = schema.enum({ "left", "right" }),
})

--- Default options for the sidepanel.
--- @class PointerOptions
--- @field width number Width of the sidepanel in columns
--- @field position string Position of the sidepanel ('left' or 'right')
M.defaults = {
  width = 60,
  position = "right", -- 'left' or 'right'
}

M.options = vim.deepcopy(M.defaults)

--- Setup function to merge user options with defaults
--- @param opts table|nil Optional table of user options to override defaults
function M.setup(opts)
  opts = opts or {}

  schema.parse(optionsSchema, opts)

  M.options = vim.tbl_deep_extend("force", M.defaults, opts)
  return M.options
end

return M
