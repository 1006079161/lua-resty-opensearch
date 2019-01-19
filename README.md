# lua-resty-opensearch
阿里云开放搜索lua插件

使用方法
local opensearch = require "resty.opensearch" --开放搜索sdk
--开放搜索配置 参数
local search_config = {
	appname = '110342391';
	internet_host = 'opensearch-cn-hangzhou.aliyuncs.com';
	accesskey_id = 'LTB41jg0dDStttEz';
	accesskey_secret = '39Rs4AjdvG1O61sxvtJYjcGbCKtECX';
}


--实例化
local start_search = opensearch.new(search_config)
local test = {query="query=title:'网站源码'&&config=start:50,hit:250,format:json",fetch_fields="id;title"}
local returnhtml = start_search:search(test)
--这里返回的returnhtml是字符串哦,如果需要渲染到模板一定要记得 cjson.decode(returnhtml)
ngx.say(returnhtml)
