local SCHEMA_KEY = "schema"
local schema_cache = ngx.shared.input_schema:get(SCHEMA_KEY)

-- TODO: check if this is a request or response?
local in_body = ngx.req.body
in_body = string.gsub(in_body, "instances", "rows", 1)
in_body = string.gsub(in_body, "{", "{ \"schema\":" .. schema_cache .. ",", 1)

ngx.req.body = in_body