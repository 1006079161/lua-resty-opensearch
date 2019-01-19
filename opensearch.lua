--
-- 阿里云开放搜索 sdk
-- User: bugscaner
-- Date: 2019-01-18 15:24:35
-- Time: 下午 15:24:35

local http = require "resty.http"

local _M = {
    __version = "0.01"
}

local mt = {__index = _M}

function new(search_config)
    return setmetatable(search_config, mt)
end

function search(self, searchquery)
	local searchquery = ngx.encode_args(searchquery)
	local opensearch_path = "/v3/openapi/apps/"..self.appname.."/search";
	searchquery = string.gsub(searchquery,"'","%%27")
    local headers, err = self:_build_auth_headers(searchquery,opensearch_path)
    local url = "http://" .. headers['Host'] .. opensearch_path ..'?' .. searchquery
    if err then return nil, err end
    local res, err = self:_send_http_request(url, "GET", headers)
    if 200 ~= res.status then
		ngx.say("出错啦")
        ngx.log(ngx.ERR, res.status, err)
        return false
    end
    return res.body
end

function _sign(self, str)
    local key = ngx.encode_base64(ngx.hmac_sha1(self.accesskey_secret, str))
    return 'OPENSEARCH '.. self.accesskey_id .. ':' .. key
end

function _send_http_request(self, url, method, headers, body)
    local httpc = http.new()
    httpc:set_timeout(30000)
    local res, err = httpc:request_uri(url, {
        method = method,
        headers = headers,
        body = body
    })
    httpc:set_keepalive(30000, 10)
    return res, err
end

function _build_auth_headers(self, searchquery,opensearch_path)
	--这里传入的searchquery 是一个table   就是python里面所说的字典形式,比如：{query="query=title:'搜索'&&config=start:0,hit:1,format:json",fetch_fields="id;title"}
	--需要注意
	local utctime = string.gsub(ngx.utctime(ngx.time())," ","T").."Z" --这个是 Date
	math.randomseed(tostring(ngx.now()):reverse():sub(1, 6))
	local nonce = ngx.time()..math.random(10000,99999) --这个是
    local appname = self.appname
	local host = self.internet_host
	local http_params = opensearch_path.."?"..searchquery
    local check_param       =   "GET\n\napplication/json\n"..utctime.."\n".."x-opensearch-nonce:"..nonce.."\n"..http_params
    local headers  =	{
        ['Date']            =	utctime,
        ['X-Opensearch-Nonce']		=	nonce,
		['Content-Type']		=	"application/json",
        ['Authorization']	=	self:_sign(check_param),
        ['Connection']		=	'keep-alive',
        ['Host']            =   host
    }
    return headers
end

-- public
_M.new = new
_M.search = search

-- private
_M._build_auth_headers = _build_auth_headers
_M._send_http_request = _send_http_request
_M._sign = _sign

return _M
