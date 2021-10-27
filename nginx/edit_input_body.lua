-- For requests going from Vertex to MLeap, edit the input data to make it
-- compatible with MLeap
-- From: { "instances" [...[...] OR {... }]"}
-- To: { "schema ": [ { "name": ..., "type": ...}], "rows": [[...]...]}
-- It does this by appending the schema to the JSON and changing the key name of "rows"

local cjson = require "cjson"
local schema = require "mleap_schema"

ngx.req.read_body()
local in_body = ngx.req.get_body_data()
local body_table = cjson.decode(in_body)
if body_table.instances == nil then
    ngx.log(ngx.WARN, "'instances' key not found in the input data.")
end

local rows_out = {}
for i, instance in ipairs(body_table.instances) do
    if instance[1] == nil then
        local row_out = {}
        -- Instance is a dictionary. Reshape to array
        for i, schema_field in ipairs(schema.dict.fields) do
            row_out[i] = instance[schema_field.name]
        end
        rows_out[i] = row_out
    else
        -- MLeap expects arrays, so just copy it over
        rows_out[i] = instance
    end
end

-- Reshape the input body to the right keys
body_table.rows = rows_out
body_table.instances = nil
body_table.schema = schema.dict

local out_body = cjson.encode(body_table)
ngx.req.set_body_data(out_body)