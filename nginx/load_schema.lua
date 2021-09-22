-- TODO: use safe library
local cjson = require "cjson"

local FILE_PATH = "/root/input_schema.json"
local SCHEMA_KEY = "schema"
local schema_cache = ngx.shared.input_schema

-- Load the file into a string


-- TODO: error handling - what if file doesn't exist?
local file_reader = io.open(FILE_PATH, "r")
local file_string = file_reader:read("a")
file_reader:close()

-- Get the schema from the file
-- [[
local schema_table = cjson.decode(file_string)
for k,v in pairs(schema_table) do
  if k != "schema" then
    schema_table[k] = nil
  end
end
-- ]]

local out_string = cjson.encode(schema_table.schema)
schema_cache:set(SCHEMA_KEY, out_string)

-- TODO: error handling - what if json doesn't exist?
-- TODO: error handling - what if it doesn't have schema key

