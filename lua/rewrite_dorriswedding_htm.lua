require ("common.helper")
dofile "/etc/nginx/lua/config.lua"

-- for test
-- dofile "/usr/local/etc/openresty/lua/config.lua"

-- if not in rewrite htm, then rewrite to html
if IsInTable(ngx.var.path, dorriswedding_need_htm)  == false then
    ngx.req.set_uri( "/" .. ngx.var.path .. ".html", true)
end