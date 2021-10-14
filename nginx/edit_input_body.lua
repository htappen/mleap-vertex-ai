-- For requests going from Vertex to MLeap, edit the input data to make it
-- compatible with MLeap
-- From: { "instances" [...[...]]"}
-- To: { "schema ": [ { "name": ..., "type": ...}], "rows": [[...]...]}
-- It does this by appending the schema to the JSON and changing the key name of "rows"

local SCHEMA_KEY = "schema"
local schema_cache = ngx.shared.input_schema:get(SCHEMA_KEY)

ngx.req.read_body()
local in_body = ngx.req.get_body_data()
in_body = string.gsub(in_body, "instances", "rows", 1)
in_body = string.gsub(in_body, "{", "{ \"schema\":" .. schema_cache .. ",", 1)

ngx.req.set_body_data(in_body)