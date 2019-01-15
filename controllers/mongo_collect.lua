mongo_collect = {}

local cjson = require("cjson")
local response_body = require("utils.response_body")
local mongo = require "resty.mongol"
local os = require('os')
local printtable = require "utils.print_table"
local mongo_host = os.getenv("MONGO_HOST")
local mongo_port = os.getenv("MONGO_PORT")
local mongo_db = os.getenv("MONGO_DB")
local expire_day = os.getenv("EXPIRE_DAY")
local adapter_url=os.getenv("ADAPTER_URL")

local http = require "resty.http" 
local httpc = http:new()
--获取连接对象

local conn = mongo:new()
conn:set_timeout(10000)

--获取连接的客户端


function mongo_collect:test_mongo_connect()

	--printtable:print_r(conn)
	--获取连接的客户端
	local  ok, err = conn:connect(mongo_host,mongo_port)
	if not ok then
		ngx.say("连接mongo库失败")
	else
		--获取数据库
		local db = conn:new_db_handle("cimp_gz_local")
		--获取集合
		local coll = db:get_col("mediaAsset")
		local coll_insert = db:get_col("collect")

		--获取document集合,查询--------------------------
		local cursor = coll:find({})
		
		--for index, item in cursor:pairs() do
			
				--ngx.say('数据'..index..";;;;deleteTime="..item["deleteTime"]..";type="..item["type"])
			

		--end


		--插入集合
		local  insertData={id="测试的视频id",name="测试的视频name"}
		local  bson1 = {device_id="哈哈哈",user_id="用户的id",type="视频的类型", date="2018-02-27",data= insertData,inserted_date=os.date()}
		--插入table表中
		local docs = {bson1}

		local rsOk, err = coll_insert:insert(docs, 0,0)

		if err then 
        	ngx.say('error--'..err)
		else 
        	ngx.say('插入成功'..rsOk)
		end

		local cursor = coll_insert:find({})
		for index, item in cursor:pairs() do
			
				ngx.say('数据'..index..";;;;user_id="..item["user_id"]..";device_id="..item["device_id"])
			

		end



		--删除数据
		--local  deOk, err = coll_insert:delete({})	

		--if err then
		--		ngx.say("删除失败")
		--else 
		--		ngx.say("删除成功")
		--end


		--ngx.say("删除后的数据结构")
		--local cursor = coll_insert:find({})
	--	for index, item in cursor:pairs() do
			
		--		ngx.say('数据'..index..";;;;user_id="..item["user_id"]..";device_id="..item["device_id"])
			

	--	end



		return {json = response_body.build(200,"采集成功")}
	end

	
end

--新闻采集
--http://blog.csdn.net/leonardo9029/article/details/51027841
--function mongo_collect:cimp_news_collect(device_id, user_id, news_type, content_id, title, keyword, play_time, resource, category_name)
function mongo_collect:cimp_news_collect(device_id, user_id, news_type,data)
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
		local colleciton_num = t1 % 10

		print("==========================="..colleciton_num)
		--获取集合
		local coll_insert = db:get_col("collect_"..colleciton_num)

		--组装采集的数据
		local  insertData=data
		local  collec_date = os.date("%Y-%m-%d")
		local  bson1 = {device_id=device_id,user_id=user_id,type=news_type, data=insertData,date=collec_date,status=0,inserted_date=os.date(),updated_at=os.date()}    --date:采集时间，inserted_at:采集开始时间，updated_at:采集结束时间
		--插入table表中
		local docs = {bson1}
		
		printtable:print_r(docs)
		-- local rsOk, insert_err = coll_insert:insert(docs)
		local insert_err, rsOk = coll_insert:insert(docs)
		-- print("插入数据---------------------------------------------------------")
		-- printtable:print_r(insert_err)
		-- print("插入数据---------------------------------------------------------|||||||||||||||||||||||||||||")
		-- printtable:print_r(rsOk)
		-- if insert_err~=nil then
		-- 	print("mongo数据库采集失败")
		-- 	-- return {json = response_body.build(500,"采集失败")}
		-- else 
		-- 	print("mongo数据库采集失败")
		-- 	-- return {json = response_body.build(200,"采集成功")}
		-- end

	end
end

--清除采集的数据
function mongo_collect:clear_collect_data()
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
		local for_i = colleciton_num+1
		local for_to_del_tables = to_del_tables+1
		for i=for_i, to_del_tables do
			local coll_del = db:get_col("collect_"..i)
			print("要清除的表="..i)
			--清除数据
			local  deOk, err = coll_del:delete({})	

			if err then
				ngx.say("清除表collect"..i.."失败")
			else 
				ngx.say("清除表collect"..i.."成功")
			end

		end


	end

	return {json = response_body.build(200,"清除成功")}
end


--调用http地址转发到适配器
function mongo_collect:gz_http_adapter(device_id, user_id, news_type,data)

	mongo_collect:cimp_news_collect(device_id,user_id, news_type, data)
	local postData = {}

	-- print("whlhwlhwlhwlhwlhwlhwlw------------")
	printtable:print_r(data)
	-- print("whlhwlhwlhwlhwlhwlhwlw------------||||||||||||||||||||||||")
	local  event={}
	local  collect_date = os.date("%Y-%m-%d")
	event["user_id"]=user_id;
	event["device_id"]=device_id;
	event["type"]=news_type
	event["data"]=data
	event["date"]=collect_date
	
	postData["event"]=event
	-- print("=========================")
	-- print("date="..collect_date)
	-- printtable:print_r(postData)
	-- print("444444444444444444444444444444444")
	---开始http请求
	-- local  vicmmamUrl="http://mam.lntv.com:8090/vicmmam/ws/checkUniquenssKey"
	local  adapterPushUrl="http://"..adapter_url.."/api/v1/events/push"
	print("适配器的url===="..adapterPushUrl)
	--调用媒资的判重接口begin-----------------------------------------------------------------
	--在请求body
	local raw_data = string.rep(cjson.encode(postData), 1)
	--print ("发送的body="..raw_data)
	local chunked = {
	                string.format("%x", #raw_data),
	                "\r\n",
	                raw_data,
	                "\r\n",
	                "0\r\n\r\n",
	}

	--end

	local res, err = httpc:request_uri(adapterPushUrl, {
	method = "POST",
	body = chunked,
	headers = {
		 ["User-Agent"] = "lua-resty-http",
		 ["Transfer-Encoding"] = "chunked",
		 ["Content-Type"]="application/json"
	 }
	})
	

	-- printtable:print_r(res)


	response_body1 = {}

	-- local body = cjson.decode(res.body)

	-- local statusCode=body.statusCode
	--结束http请求
	if err then
			return {json = response_body.build(500,"采集失败")}
		else 
			return {json = response_body.build(200,"采集成功")}
	end




end

return  mongo_collect