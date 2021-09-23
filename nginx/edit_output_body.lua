local cjson = require "cjson"
local output_key_name = os.getenv("OUTPUT_KEY")

-- TODO: not really going to work with large responses. Need to deal with chunking
if not ngx.arg[2] then
    local mleap_json = cjson.decode(ngx.arg[1])
    local key_position = 0
    for i, schema_field in ipairs(mleap_json.schema.fields) do
        if schema_field.name == output_key_name then
            key_position = i
            break
        end
    end

    -- TODO: error handling, what to do if it's not found? Can I set an error response?
    local predictions_out = {}
    for i, row in ipairs(mleap_json.rows) do
        predictions_out[i] = row[key_position]
    end
    local json_out = { ["predictions"]=predictions_out }

    ngx.arg[1] = cjson.encode(json_out)
end