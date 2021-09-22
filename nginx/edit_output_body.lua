local out_body = ngx.arg[1]
ngx.arg[1] = out_body:gsub("rows", "predictions", 1)