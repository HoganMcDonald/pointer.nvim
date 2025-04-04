--- Schema validation library for Lua
---@class SchemaModule
---@generic T: Schema
local M = {}

---@class SchemaValidationResult
---@field success boolean Whether validation succeeded
---@field error? string Error message when validation fails (single error)
---@field errors? string[] List of error messages when validation fails (multiple errors)
---@field data? any The validated data (only present in successful safeParse results)

---@class Schema
---@field type string The schema type
---@field _optional boolean Whether the schema allows nil values
---@field optional fun(self: Schema): Schema Make this schema optional
---@field validate fun(self: Schema, value: any, path?: string): SchemaValidationResult Validate a value against this schema

--- Create base schema type
---@generic T: Schema
---@param type_name string The name of the schema type
---@return T The new schema instance
local function new_schema(type_name)
  local schema = {
    type = type_name,
    _optional = false,
  }

  --- Make this schema optional
  ---@generic T: Schema
  ---@return T The optional schema
  function schema:optional()
    local new = vim.deepcopy(self)
    new._optional = true
    return new
  end

  return schema
end

---@class StringSchema : Schema
---@field optional fun(self: StringSchema): StringSchema Make this schema optional
---@field validate fun(self: StringSchema, value: any, path?: string): SchemaValidationResult Validate a value against this schema

--- Create a string schema
---@return StringSchema
function M.string()
  local schema = new_schema("string")

  --- Validate a value against this schema
  ---@param value any The value to validate
  ---@param path? string The path to the value (for error messages)
  ---@return SchemaValidationResult
  function schema:validate(value, path)
    path = path or "value"

    if value == nil then
      if self._optional then
        return { success = true }
      else
        return { success = false, error = path .. " is required" }
      end
    end

    if type(value) ~= "string" then
      return { success = false, error = path .. " must be a string, got " .. type(value) }
    end

    return { success = true }
  end

  return schema
end

---@class NumberSchema : Schema
---@field optional fun(self: NumberSchema): NumberSchema Make this schema optional
---@field validate fun(self: NumberSchema, value: any, path?: string): SchemaValidationResult Validate a value against this schema

--- Create a number schema
---@return NumberSchema
function M.number()
  local schema = new_schema("number")

  --- Validate a value against this schema
  ---@param value any The value to validate
  ---@param path? string The path to the value (for error messages)
  ---@return SchemaValidationResult
  function schema:validate(value, path)
    path = path or "value"

    if value == nil then
      if self._optional then
        return { success = true }
      else
        return { success = false, error = path .. " is required" }
      end
    end

    if type(value) ~= "number" then
      return { success = false, error = path .. " must be a number, got " .. type(value) }
    end

    return { success = true }
  end

  return schema
end

---@class BooleanSchema : Schema
---@field optional fun(self: BooleanSchema): BooleanSchema Make this schema optional
---@field validate fun(self: BooleanSchema, value: any, path?: string): SchemaValidationResult Validate a value against this schema

--- Create a boolean schema
---@return BooleanSchema
function M.boolean()
  local schema = new_schema("boolean")

  --- Validate a value against this schema
  ---@param value any The value to validate
  ---@param path? string The path to the value (for error messages)
  ---@return SchemaValidationResult
  function schema:validate(value, path)
    path = path or "value"

    if value == nil then
      if self._optional then
        return { success = true }
      else
        return { success = false, error = path .. " is required" }
      end
    end

    if type(value) ~= "boolean" then
      return { success = false, error = path .. " must be a boolean, got " .. type(value) }
    end

    return { success = true }
  end

  return schema
end

---@class EnumSchema : Schema
---@field _values string[] Allowed enum values
---@field optional fun(self: EnumSchema): EnumSchema Make this schema optional
---@field validate fun(self: EnumSchema, value: any, path?: string): SchemaValidationResult Validate a value against this schema

--- Create an enum schema
---@param values string[] Allowed enum values
---@return EnumSchema
function M.enum(values)
  local schema = new_schema("enum")
  schema._values = values

  --- Validate a value against this schema
  ---@param value any The value to validate
  ---@param path? string The path to the value (for error messages)
  ---@return SchemaValidationResult
  function schema:validate(value, path)
    path = path or "value"

    if value == nil then
      if self._optional then
        return { success = true }
      else
        return { success = false, error = path .. " is required" }
      end
    end

    if type(value) ~= "string" then
      return { success = false, error = path .. " must be a string, got " .. type(value) }
    end

    for _, v in ipairs(self._values) do
      if value == v then return { success = true } end
    end

    return {
      success = false,
      error = path .. " must be one of: " .. table.concat(self._values, ", ") .. ", got " .. value,
    }
  end

  return schema
end

---@class ObjectSchema : Schema
---@field _shape table<string, Schema> Shape definition for object properties
---@field _strict boolean Whether to reject unknown properties
---@field optional fun(self: ObjectSchema): ObjectSchema Make this schema optional
---@field strict fun(self: ObjectSchema): ObjectSchema Reject unknown properties
---@field passthrough fun(self: ObjectSchema): ObjectSchema Allow unknown properties
---@field validate fun(self: ObjectSchema, value: any, path?: string): SchemaValidationResult Validate a value against this schema

--- Create an object schema
---@param shape table<string, Schema> Shape definition for object properties
---@return ObjectSchema
function M.object(shape)
  local schema = new_schema("object")
  schema._shape = shape
  schema._strict = true -- Default to strict mode

  --- Validate a value against this schema
  ---@param obj any The value to validate
  ---@param path? string The path to the value (for error messages)
  ---@return SchemaValidationResult
  function schema:validate(obj, path)
    path = path or "value"

    if obj == nil then
      if self._optional then
        return { success = true }
      else
        return { success = false, error = path .. " is required" }
      end
    end

    if type(obj) ~= "table" then
      return { success = false, error = path .. " must be a table, got " .. type(obj) }
    end

    local errors = {}

    -- Validate each field against its schema
    for field, fieldSchema in pairs(self._shape) do
      local fieldPath = path .. "." .. field
      local fieldValue = obj[field]

      local result = fieldSchema:validate(fieldValue, fieldPath)
      if not result.success then table.insert(errors, result.error) end
    end

    -- In strict mode, check for extra fields
    if self._strict then
      for field, _ in pairs(obj) do
        if not self._shape[field] then
          table.insert(errors, path .. "." .. field .. " is not recognized")
        end
      end
    end

    if #errors > 0 then return { success = false, errors = errors } end

    return { success = true }
  end

  --- Configure strict mode
  ---@return ObjectSchema
  function schema:strict()
    self._strict = true
    return self
  end

  --- Configure passthrough mode
  ---@return ObjectSchema
  function schema:passthrough()
    self._strict = false
    return self
  end

  return schema
end

--- Parse data against a schema, throwing an error if validation fails
---@param schema Schema The schema to validate against
---@param data any The data to validate
---@return any data The validated data
function M.parse(schema, data)
  local result = schema:validate(data)

  if not result.success then
    local errorMsg = "Invalid configuration:"

    if result.error then
      errorMsg = errorMsg .. "\n- " .. result.error
    elseif result.errors then
      for _, err in ipairs(result.errors) do
        errorMsg = errorMsg .. "\n- " .. err
      end
    end

    error(errorMsg, 2)
  end

  return data
end

--- Parse data against a schema, returning a result object instead of throwing
---@param schema Schema The schema to validate against
---@param data any The data to validate
---@return SchemaValidationResult result The validation result
function M.safeParse(schema, data)
  local result = schema:validate(data)

  if not result.success then
    local errors = {}

    if result.error then
      table.insert(errors, result.error)
    elseif result.errors then
      errors = result.errors
    end

    return { success = false, errors = errors }
  end

  return { success = true, data = data }
end

return M
