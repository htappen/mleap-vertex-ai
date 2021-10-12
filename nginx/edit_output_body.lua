local cjson = require "cjson"
local output_key_name = os.getenv("OUTPUT_KEY") -- TODO: support multiple keys

local function edit_json(body)
    local mleap_json = cjson.decode(body)
    local key_position = 0
    for i, schema_field in ipairs(mleap_json.schema.fields) do
        if schema_field.name == output_key_name then
            key_position = i
            break
        end
    end

    local predictions_out = {}
    for i, row in ipairs(mleap_json.rows) do
        predictions_out[i] = row[key_position]
    end
    local json_out = { ["predictions"]=predictions_out }

    return cjson.encode(json_out)
end

local function edit_body()
    return edit_json(ngx.arg[1])
end

local ok_prediction = true
-- TODO: not really going to work with large responses. Need to deal with chunking
if not ngx.arg[2] then
    local pcall_succeeded, new_body = pcall(edit_body)
    if pcall_succeeded then
        ngx.arg[1] = new_body
    else
        ok_prediction = false
        ngx.log(ngx.WARN, "Error in reformatting:" .. new_body)
        ngx.log(ngx.WARN, "Return value from MLeap" .. ngx.arg[1])
    end
else
    ngx.arg[1] = ""
end

if not ok_prediction then
    ngx.status = ngx.BAD_REQUEST
    ngx.log(ngx.WARN, "Reformatting prediction from MLeap failed")
    ngx.arg[1] = ""
end