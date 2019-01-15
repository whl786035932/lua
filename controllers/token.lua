--认证controller

token = {}
local response_body = require("utils.response_body")
local printtable = require "utils.print_table"
local http = require "resty.http" 
local httpc = http:new()
local cjson = require("cjson")
cjson.encode_empty_table_as_object(false)

---------------------------------------------贵州
--贵州的认证接口
function token:token_qian(nns_tag, nns_version,  nns_func,  nns_mac_id, nns_device_id, nns_output_type)

	--http 请求贵州认证接口
	local  token_url = "http://10.21.4.236/gzgd/AAAAuth?nns_tag="..nns_tag.."&nns_version="..nns_version.."&nns_func="..nns_func.."&nns_mac_id="..nns_mac_id.."&nns_device_id="..nns_device_id.."&nns_output_type="..nns_output_type
	print("--------------------------------------token_url="..token_url)
	local res, err = httpc:request_uri(token_url, {
	 method = "GET",
	 headers = {
		 ["Content-Type"] = "application/json"
	 }
	 })
	
	
	

	
	if res~=nil then
		print "get   result=============================================="
		printtable:print_r(res)
	end
	local body = cjson.decode(res.body)
	
	--根据返回response,取到state值和token值
	local  web_token = ""
	local  response_state = body.result.state
	if response_state == 300000 then
		 web_token = body.auth.web_token
	end
	
	print("请求的时间~~~~~~~~~~~~~~~~~outerouter~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~begin")
	-- print(os.time())
	local  collec_date = os.date("%Y-%m-%d %H:%M:%S")
	print(collec_date)
	print("请求的时间~~~~~~~~~~~~~~~~~~~~~~outerouter~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~end")

	return {json = token.build_response_qian(response_state, web_token)}

end

--构建贵州的返回结构
function token.build_response_qian(web_state,web_token)
	response_qian = {}
	response_qian["state"] =  web_state
	response_qian["web_token"] = web_token
	return response_qian
end


------------------------------------------------------本地

--本地认证，直接通过认证,直接返回300000和web_token
function token:token_wangbo()

	print("local  token passed")
	return {json = token.build_response_qian(300000, "wangbo_token") }

end



-----------------------------------------------------江西
function  token:token_gan()
end





return token
