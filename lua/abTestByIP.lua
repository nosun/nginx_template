-- for test
-- ngx.say('hello')

local redis = require "resty.redis"

local getClientIP = function()
    if ngx.req.get_headers()["X-Real-IP"] then
        return ngx.req.get_headers()["X-Real-IP"]
    elseif ngx.req.get_headers()["x_forwarded_for"] then
        return ngx.req.get_headers()["x_forwarded_for"]
    else
        return ngx.var.remote_addr
    end
end

local clientIP = getClientIP()

-- for test
-- ngx.say(clientIP)

local getRandomServer = function()

    local serverA  = 'server1'
    local serverB  = 'server2'
    local rate     = 30

    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    local random = math.random(1,100)

    if random <= rate then
        return serverB
    else
	return serverA
    end
end

local red = redis:new()
red:set_timeout(1000) -- 1 sec
--local ok, err = red:connect("127.0.0.1", 6379)

local ok, err = red:connect("unix:/tmp/redis.sock")

if not ok then
    ngx.say("failed to connect: ", err)
    return
end

-- ngx.say(getRandomServer())

local res, err = red:get(clientIP)

if not res then
    ngx.say("failed to get clientIP", err)
    return
end

-- if the ip not in redis, then get random server
-- and set it to redis, else set res to server

if res == nil or res == ngx.null then
    server  = getRandomServer()
    -- ngx.say(server)

    red:set(clientIP, server)
    red:sadd(server,clientIP)

else
    server = res
end

-- ngx.say(server)

ngx.exec("@" .. server)

-- put it into the connection pool of size 100,
-- with 10 seconds max idle time
local ok, err = red:set_keepalive(10000, 100)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end
