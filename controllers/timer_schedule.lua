local delayInSeconds  = 3


local cjson = require("cjson")
local response_body = require("utils.response_body")
local mongo = require "resty.mongol"

local http = require "resty.http" 

local resty_lock = require "resty.lock"

local os = require('os')
local printtable = require "utils.print_table"
local mongo_host = os.getenv("MONGO_HOST")
local mongo_port = os.getenv("MONGO_PORT")
local mongo_db = os.getenv("MONGO_DB")
local expire_day = os.getenv("EXPIRE_DAY")
--获取连接对象

--local conn = mongo:new()
--conn:set_timeout(10000)







week_del_collectData = function()
	
	print("开启了一个定时任务啊，奶奶的")

	--加锁
	local lock,err = resty_lock:new("my_locks")
	if not lock then
		print("加锁失败")
	end
	local elapsed, err = lock:lock("my_key")
	print("lock:"..elapsed..";err="..err)


	--开始请求
	--local del_collectData_url =  "http://10.2.16.236:8090/enews4tv/api/categories"
	--local res, err = httpc:request_uri(del_collectData_url, {
	-- method = "GET",
	-- headers = {
	--	 ["Content-Type"] = "application/json"
	-- }
	-- })
	
	--if res~=nil then
	--	print "get   result=============================================="
	--	printtable:print_r(res)
	--end
	--local body = cjson.decode(res.body)

	--解锁
	local ok,err = lock:unlock()
	if not ok then
		print("解锁失败"..err)
	end



	local ok, err = ngx.timer.at(delayInSeconds,week_del_collectData)
	if not ok then
		print("开启定时任务失败,咋整咋整咋整")
	end
end



week_del_newsCollectData= function()
	
	local  ok, err = conn:connect(mongo_host,mongo_port)
	if not ok then
		ngx.say("连接mongo库失败")
	else
		--ngx.say("数据库名="..mongo_db)
		--获取数据库
		local db = conn:new_db_handle(mongo_db)
		--获取当前的日期
		local now_date_seconds = os.time()
		--根据日期对10取模
		local t1,t2 =	math.modf(now_date_seconds/86400)
		local colleciton_num = t1 % 10  --当期日期的对应的表collect_1

		--根据算法算出要删除的哪几张表

		local to_del_tables = colleciton_num + 10 -expire_day    --该值为4，要删除collect_2，collect_3, collect_4

		for i=colleciton_num, i<=to_del_tables do
			local coll_del = db:get_col("collect_"..i)
			--清除数据
			local  deOk, err = coll_del:delete({})	

			if err then
				ngx.say("清除表collect"..i.."失败")
			else 
				ngx.say("清除表collect"..i.."成功")
			end

		end


	end
	local ok, err = ngx.timer.at(delayInSeconds,week_del_newsCollectData)


end




week_del_collectData()