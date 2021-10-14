-- After MLeap processes a request, this script translates the result to a format compatible with Vertex AI
-- From: { "schema ": [ { "name": ..., "type": ...}], "rows": [[...]...]}
-- To: { "predictions" [...[...]]"}
-- This script needs to take one of the output keys and return it as a prediction

local cjson = require "cjson"
local output_key_name = os.getenv("OUTPUT_KEY") -- TODO: support multiple keys

if output_key_name == nil then
    ngx.log(ngx.WARN, "OUTPUT_KEY_NAME isn't found. Please send environment variable")
end

-- Do the actual conversion of a MLeap JSON format to Vertex required
local function edit_json(body)
    -- Find out which slot in the output array contains the final prediction
    local mleap_json = cjson.decode(body)
    local key_position = 0
    for i, schema_field in ipairs(mleap_json.schema.fields) do
        if schema_field.name == output_key_name then
            key_position = i
            break
        end
    end

    if key_position == 0 then
        ngx.log(ngx.WARN, "Key " .. output_key_name .. "was not found in the schema. Update the schema or env var OUTPUT_KEY")
    end

    -- Grab the prediction result from each output
    local predictions_out = {}
    for i, row in ipairs(mleap_json.rows) do
        predictions_out[i] = row[key_position]
    end
    local json_out = { ["predictions"]=predictions_out }

    return cjson.encode(json_out)
end

-- Apply edit_json only to the body content
local function edit_body()
    return edit_json(ngx.arg[1])
end

-- Try / catch on editing the body
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