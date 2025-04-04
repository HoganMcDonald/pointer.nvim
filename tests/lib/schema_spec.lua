local M = {}

---@type SchemaModule
local describe, it = require("plenary.busted").describe, require("plenary.busted").it
local assert = require("luassert")
local schema = require("pointer.lib.schema")

describe("Schema Library", function()
  describe("string schema", function()
    it("should validate string values", function()
      local str_schema = schema.string()
      local result = str_schema:validate("hello")
      assert.equals(true, result.success)
    end)

    it("should reject non-string values", function()
      local str_schema = schema.string()
      local result = str_schema:validate(123)
      assert.equals(false, result.success)
      assert.equals("value must be a string, got number", result.error)
    end)

    it("should handle optional strings", function()
      local str_schema = schema.string():optional()
      local result = str_schema:validate(nil)
      assert.equals(true, result.success)
    end)

    it("should reject nil for required strings", function()
      local str_schema = schema.string()
      local result = str_schema:validate(nil)
      assert.equals(false, result.success)
      assert.equals("value is required", result.error)
    end)
  end)

  describe("number schema", function()
    it("should validate number values", function()
      local num_schema = schema.number()
      local result = num_schema:validate(123)
      assert.equals(true, result.success)
    end)

    it("should reject non-number values", function()
      local num_schema = schema.number()
      local result = num_schema:validate("123")
      assert.equals(false, result.success)
      assert.equals("value must be a number, got string", result.error)
    end)

    it("should handle optional numbers", function()
      local num_schema = schema.number():optional()
      local result = num_schema:validate(nil)
      assert.equals(true, result.success)
    end)
  end)

  describe("boolean schema", function()
    it("should validate boolean values", function()
      local bool_schema = schema.boolean()
      local result = bool_schema:validate(true)
      assert.equals(true, result.success)
    end)

    it("should reject non-boolean values", function()
      local bool_schema = schema.boolean()
      local result = bool_schema:validate("true")
      assert.equals(false, result.success)
      assert.equals("value must be a boolean, got string", result.error)
    end)

    it("should handle optional booleans", function()
      local bool_schema = schema.boolean():optional()
      local result = bool_schema:validate(nil)
      assert.equals(true, result.success)
    end)
  end)

  describe("enum schema", function()
    it("should validate enum values", function()
      local enum_schema = schema.enum({ "red", "green", "blue" })
      local result = enum_schema:validate("red")
      assert.equals(true, result.success)
    end)

    it("should reject invalid enum values", function()
      local enum_schema = schema.enum({ "red", "green", "blue" })
      local result = enum_schema:validate("yellow")
      assert.equals(false, result.success)
      assert.equals("value must be one of: red, green, blue, got yellow", result.error)
    end)

    it("should handle optional enums", function()
      local enum_schema = schema.enum({ "red", "green", "blue" }):optional()
      local result = enum_schema:validate(nil)
      assert.equals(true, result.success)
    end)
  end)

  describe("object schema", function()
    it("should validate object values", function()
      local obj_schema = schema.object({
        name = schema.string(),
        age = schema.number(),
      })
      local result = obj_schema:validate({ name = "John", age = 30 })
      assert.equals(true, result.success)
    end)

    it("should reject invalid object values", function()
      local obj_schema = schema.object({
        name = schema.string(),
        age = schema.number(),
      })
      local result = obj_schema:validate({ name = "John", age = "30" })
      assert.equals(false, result.success)
      assert.equals("value.age must be a number, got string", result.errors[1])
    end)

    it("should handle optional objects", function()
      local obj_schema = schema
        .object({
          name = schema.string(),
          age = schema.number(),
        })
        :optional()
      local result = obj_schema:validate(nil)
      assert.equals(true, result.success)
    end)

    it("should handle strict mode", function()
      local obj_schema = schema
        .object({
          name = schema.string(),
          age = schema.number(),
        })
        :strict()
      local result = obj_schema:validate({ name = "John", age = 30, extra = "field" })
      assert.equals(false, result.success)
      assert.equals("value.extra is not recognized", result.errors[1])
    end)

    it("should handle passthrough mode", function()
      local obj_schema = schema
        .object({
          name = schema.string(),
          age = schema.number(),
        })
        :passthrough()
      local result = obj_schema:validate({ name = "John", age = 30, extra = "field" })
      assert.equals(true, result.success)
    end)
  end)

  describe("parse function", function()
    it("should return data on successful validation", function()
      local str_schema = schema.string()
      local result = schema.parse(str_schema, "hello")
      assert.equals("hello", result)
    end)

    it("should throw error on failed validation", function()
      local str_schema = schema.string()
      local success, err = pcall(function() schema.parse(str_schema, 123) end)
      assert.equals(false, success)
      assert.matches("Invalid configuration:", err)
    end)
  end)

  describe("safeParse function", function()
    it("should return success with data on successful validation", function()
      local str_schema = schema.string()
      local result = schema.safeParse(str_schema, "hello")
      assert.equals(true, result.success)
      assert.equals("hello", result.data)
    end)

    it("should return failure with errors on failed validation", function()
      local str_schema = schema.string()
      local result = schema.safeParse(str_schema, 123)
      assert.equals(false, result.success)
      assert.equals("value must be a string, got number", result.errors[1])
    end)
  end)
end)

return M

