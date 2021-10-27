-- Initialization script that loads a schema saved in JSON into memory.
-- OpenResty caches loaded modules per workers, so the init should only happen once
-- See https://github.com/openresty/lua-nginx-module#data-sharing-within-an-nginx-worker

local cjson = require "cjson"
local FILE_PATH = "/root/input_schema.json"

ngx.log(ngx.INFO, "Loading schema from file")

-- Load the file into a string
local file_reader, err = io.open(FILE_PATH, "r")
if file_reader == nil then
    ngx.log(ngx.WARN, "Input schema is not found. Did you set MLEAP_SCHEMA_URI? Error: " .. err )
end
local file_string = file_reader:read("a")
file_reader:close()

-- Get the schema from the file
local schema_table = cjson.decode(file_string)
for k,v in pairs(schema_table) do
  if k ~= "schema" then
    schema_table[k] = nil
  end
end

if schema_table.schema == nil then
    ngx.log(ngx.WARN, "'schema' key not found in the input file.")
end

return {
    ["dict"] = schema_table.schema
}