local lapis = require("lapis")
local db = require("lapis.db")
local app = lapis.Application()
local respond_to = require("lapis.application").respond_to
local category = require("controllers.category")
local area = require("controllers.area")
local ad = require("controllers.ad")
local area_doe = require("controllers.area_code")
local content_area_mapping = require("controllers.content_area_mapping")
local content_column_mapping = require("controllers.content_column_mapping")
local content_mapping = require("controllers.content_mapping")

local content = require("controllers.content")
local cjson = require("cjson")
cjson.encode_empty_table_as_object(false)
local response_body = require("utils.response_body")

local http = require "resty.http" 
local httpc = http:new()

local token = require "controllers.token"

local authorize = require "controllers.authorize"
local os = require('os')
local response_body = require("utils.response_body")

local usersub =  require"controllers.userSub"
local tag = require "controllers.tag"
local search_es = require "controllers.search_es"
local printtable = require "utils.print_table"

local mongo_collect = require "controllers.mongo_collect"
local string_util = require "utils.string_util"
local printtable = require "utils.print_table"


app:get("/", function()
  return "Welcome to Lapis " .. require("lapis.version")
end)

--get all categories
--app:match("/enews4tv/api/categories",respond_to(category))
app:match("/enews4tv/api/categories",function()
	return  category:getAll()
end)

--get first level categories
app:get("/enews4tv/api/first/categories",function() 
	return category:firstCategory()
end)
--get child categories
app:get("/enews4tv/api/:category_id/categories/child",function(self)
	return category:getChildCategory(self.params.category_id)
end)
--get  政要栏目信息
app:get("/enews4tv/api/categorys/:category_id",function(self)
	return category:getCategoryInfo(self.params.category_id)
end) 

--get  区域市级
app:get("/enews4tv/api/areas",function(self)
	 return area:getFirstAreas()
end)

app:get("/enews4tv/api/:area_id/areas",function(self)

	 return area:getChildAreas(self.params.area_id)
end)

--get 广告
app:get("/enews4tv/api/:position/ad",function(self) 
	 return  ad:getAdByPosition(self.params.position)
end)

-- 地区码转地区
app:get("/enews4tv/api/news/:code/area",function(self)
	return area_doe:getAreaByCode(self.params.code)
end)


-- 根据地区查出新闻列表
app:get("/enews4tv/api/news/area", function(self)
		local area = self.params.area
		local map_id = self.params.map_id
		local limit = self.params.limit
		

		return content_area_mapping:getNewsByArea(area, map_id, limit)
end)


--根据地区栏目+城市获取新闻列表
app:get("/enews4tv/api/news/:category_id/category/area",function(self)
		
		local area = self.params.area
		local category_id = self.params.category_id
		local map_id = self.params.map_id
		local limit = self.params.limit
		return content_column_mapping:getNewsByAreaAndColumn(area, category_id, map_id, limit)


	end

)


--新闻列表，单个栏目新闻，按照新闻的publish_time搜索
app:get("/enews4tv/api/newsByCategory",function(self)
	local category_id= self.params.category_id
	local map_id = self.params.map_id
	local limit = self.params.limit
	return content_column_mapping:getNewsByColumn(category_id,map_id, limit)

	
end)


--新闻列表(栏目推荐新闻),按照sequence排序
app:get("/enews4tv/api/newsByCategory/recommend",function(self)
	print("栏目推荐新闻")
	local category_id= self.params.category_id
	local map_id = self.params.map_id
	local limit = self.params.limit
	print("limit="..type(limit))
	return content_column_mapping:getNewsByColumnOrderBySequence(category_id,map_id, limit)
end)

--新闻列表，专题
app:get("/enews4tv/api/newsBySubject",function(self)
	local subject_id = self.params.subject_id
	local map_id = self.params.map_id
	local limit = self.params.limit
	return content_mapping:getNewsBySubject(subject_id, map_id, limit)

end)


--新闻搜索,标题首字母
app:get("/enews4tv/api/news/search",function(self) 
	local keyword = self.params.keyword
	local map_id = self.params.map_id
	local limit = self.params.limit
	return  content:searchByKeyword(keyword, map_id, limit)


end)



--新闻详情
app:get("/enews4tv/api/news/:news_id",function(self)
	return content:get(self.params.news_id)
end)

--搜索推荐
app:get("/enews4tv/api/news/recommend/search",function(self)
	local  limit = self.params.limit
	return content:getRecommendContents(limit)
end
)

--通过栏目获取新闻，按照publish_time分页+排序
app:get("/enews4tv/api/newsByCategoryAndPublishDate",function(self)
	--print("按照栏目和发布日期排序")
	local  category_id = self.params.category_id
	local  publish_date = self.params.publish_date
	local  limit = self.params.limit
	--print("发布日期publish_date="..publish_date)
	return content_column_mapping:newsByCategoryAndPublishDate(category_id, publish_date,limit)
end)







app:get("/enews4tv/api/version",function(self)
	--form data 可以获取到参数
	
	--test http resty


	return {json = response_body.build(200,"v2.0.1806071541")}

	
end)


--认证接口
app:get("/enews4tv/api/token",function(self)
	print("请求的时间~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~begin")
	-- print(os.time())
	local  collec_date = os.date("%Y-%m-%d %H:%M:%S")
	print(collec_date)
	print("请求的时间~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~end")
	local customer = os.getenv("CUSTOMER")

	--贵州的认证接口
	if customer == "qian" then     
		local nns_tag = self.params.nns_tag
		local nns_version = self.params.nns_version
		local nns_func = self.params.nns_func
		local nns_mac_id = self.params.nns_mac_id
		local nns_device_id = self.params.nns_device_id
		local nns_output_type = self.params.nns_output_type
		return token:token_qian(nns_tag, nns_version,  nns_func,  nns_mac_id, nns_device_id, nns_output_type)

	
	elseif customer == "gan" then
		--江西的认证接口
	elseif customer == "wangbo" then
		--本地的认证接口
		return token:token_wangbo()
		
	end
	

end)


--换串接口
app:get("/enews4tv/api/authorize",function(self)

	--获取客户
	local  customer = os.getenv("CUSTOMER")    
	--获取地区
	local  area = os.getenv("AREA")


	--贵州的换串接口
	if customer == "qian" and area == "qian" then

		local nns_ids =  self.params.nns_ids     --当前播放视频的url
		local nns_type = self.params.nns_type    --index
 		local nns_video_type = self.params.nns_video_type   --0
 		local nns_id_func = self.params.nns_id_func    --获取视频的id的func
 		local nns_url_func = self.params.nns_url_func   ---获取视频的url的func
 		local nns_mac = self.params.nns_mac          --盒子的设备id
 		local nns_mac_id = self.params.nns_mac_id    --盒子的设备id
 		local nns_version = self.params.nns_version   
 		local nns_user_id = self.params.nns_user_id     --盒子的id
 		local nns_webtoken = self.params.nns_webtoken          --认证接口返回的token
 		local nns_output_type =  self.params.nns_output_type   --  json


 		return  authorize:authorize_qian(nns_ids,nns_type, nns_video_type, nns_id_func,nns_url_func, nns_mac, nns_mac_id,  nns_version,  nns_user_id,  nns_webtoken, nns_output_type)


	elseif customer == "gan" and area == "gan" then
		--江西的换串接口
		local  transferIp = self.params.transferIp
		local typeId = self.params.typeId
		local playType = self.params.playType
		local progId = self.params.progId
		local contentType = self.params.contentType
		local business = self.params.business
		local baseFlag = self.params.baseFlag
		local cookie = self.params.cookie
		return authorize:authorize_gan(transferIp,typeId, playType, progId, contentType, business, baseFlag,cookie )


	elseif customer == "wangbo" and area == "qian" then

		--网博的换串接口
		local nns_ids = self.params.nns_ids
		return authorize:authorize_wangbo_qian(nns_ids)
	elseif customer == "wangbo" and area == "gan" then
		local progId = self.params.progId
		local transferIp = self.params.transferIp
		return authorize:authorize_wangbo_gan(transferIp,progId)
	end


end)


app:match("/enews4tv/api/user/subwordold",respond_to{
	POST = function(self)
		local userId = self.params.userId
		local subword = self.params.subword
		local matchword = self.params.matchword
		print("用户添加或是修改订阅号"..self.params.userId.."订阅的词="..subword)

		return usersub:addUserSub(userId,subword,matchword)
		
	end

})
--添加或是修改用户的订阅号
app:match("/enews4tv/api/user/subword",function(self)
	
	local args = ngx.req.get_post_args()
	
	local requestBodyStr = nil

	for k, v  in pairs(args) do
		requestBodyStr = k
		break;
	end
	--print("请求的字符串="..requestBodyStr)
	local requestBody = cjson.decode(requestBodyStr)
	
	local userId = requestBody["userId"]
	local subword = requestBody["subword"]
	local matchword = requestBody["machword"]
	--print("解析出来的value=="..userId..";"..subword)

	return usersub:addUserSub(userId,subword,matchword)
end)

--获取用户的订阅词和机器匹配词
app:match("/enews4tv/api/user/allWords",function(self)
	 local userId = self.params.userId
	 return usersub:getUserMachword(userId)
end)

--获取标签列表
app:get("/enews4tv/api/user/tags",function(self)
	local userId = self.params.userId
	local limit = self.params.limit
	print("获取标签列表userId="..userId.."limit="..limit)
	return  tag:getUserTags(userId, limit)
end)

--获取搜索引擎接口（根据用户的id获取用户的订阅号，然后根据用户的订阅号去搜索推荐）
app:get("/enews4tv/api/user/recommend",function(self)
	local  userId = self.params.userId
	local  size = self.params.size
	local  from = self.params.from
	local filterStr=""
	local pararmFilter=self.params.filter
	if pararmFilter~=nil then
		filterStr=pararmFilter
	end
	local filterIds=string_util:split(filterStr, ",")  
	return search_es:search_user_recommend(userId, size, from,filterIds)
end)


--测试lua接受post的RequestBody值
app:match("/enews4tv/api/testPost",function(self)
	
	local args = ngx.req.get_post_args()
	
	local requestBodyStr = nil

	for k, v  in pairs(args) do
		requestBodyStr = k
		break;
	end
	print("请求的name="..requestBodyStr)
	local requestBody = cjson.decode(requestBodyStr)
	print("name="..requestBody["name"])
end)


--测试get请求
app:match("/enews4tv/api/token_test",function(self)
		local nns_tag = self.params.nns_tag
		local nns_version = self.params.nns_version
		local nns_func = self.params.nns_func
		local nns_mac_id = self.params.nns_mac_id
		local nns_device_id = self.params.nns_device_id
		local nns_output_type = self.params.nns_output_type
		return token_test:token_qian(nns_tag, nns_version,  nns_func,  nns_mac_id, nns_device_id, nns_output_type)

end)



--测试mongo数据库的读写
app:match("/enews4tv/api/test_mongo",function(self)
	return mongo_collect:test_mongo_connect()
end)

--新闻采集接口，没有统计情况下提供的接口

-- app:match("/enews4tv/api/news/collect",function ( self )
	
	
-- 	local user_id = self.params.user_id
-- 	local news_type = self.params.type
-- 	local content_id = self.params.content_id
-- 	local title = self.params.title
-- 	local keyword = self.params.keyword
-- 	local play_time = self.params.play_time
-- 	local resource = self.params.resource
-- 	local category_name = self.params.category_name

-- 	--body 
-- 	local args = ngx.req.get_post_args()
	
-- 	local requestBodyStr = nil

-- 	for k, v  in pairs(args) do
-- 		requestBodyStr = k
-- 		break;
-- 	end
-- 	--print("请求的字符串="..requestBodyStr)
-- 	local requestBody = cjson.decode(requestBodyStr)
	
-- 	local device_id = requestBody["device_id"]
-- 	local user_id = requestBody["user_id"]
-- 	local news_type = requestBody["type"]
-- 	local data = requestBody["data"]
-- 	print("解析出来的value=="..news_type)



-- 	return mongo_collect:cimp_news_collect(device_id,user_id, news_type, data)

-- end)

--清除采集数据的接口
app:match("/enews4tv/api/news/clearCollectData",function(self)
	return mongo_collect:clear_collect_data()
end)

--贵州新闻统计提供的采集接口
app:match("/enews4tv/api/news/collect",function ( self )
	
	
	

	--body 
	local args = ngx.req.get_post_args()
	

	
	local requestBodyStr = nil

	for k, v  in pairs(args) do
		requestBodyStr = k
		break;
	end

	
	if requestBodyStr~=nil then
		print("请求的字符串="..requestBodyStr)

		local requestBody = cjson.decode(requestBodyStr)
		
		printtable:print_r(requestBody)
		
		


		local device_id = requestBody["device_id"]
		local user_id = requestBody["user_id"]
		local news_type = requestBody["type"]
		local data = requestBody["data"]
		print("解析出来的value=="..news_type)


		--没有贵州统计的系统是保存到数据库中
		-- return mongo_collect:cimp_news_collect(device_id,user_id, news_type, data)
		--现在新版的贵州统计是转发到适配器
		return mongo_collect:gz_http_adapter(device_id,user_id, news_type, data)
	else
		return {json = response_body.build(400,"采集失败")}
	end

	

end)
-----------------------------------新版的cimp接口 Date:2018-06-04
app:match("/booths/api/v1/classifications",function ( self )
	print("------------------------------------------")
	return category:buildFullTree()

end)
--------------------分类列表的子级别  ----根据id

app:get("/booths/api/v1/classifications/:classification_id",function(self)
		local classification_id = self.params.classification_id
		-- print("获取的id="..category_id)
		return category:getChildCategoryBooths(classification_id)
end)

--------------------分类列表的子级别  ----根据name

app:get("/booths/api/v1/classifications/childClassificationByName",function(self)
		local classification_name = self.params.classification_name
		-- print("获取的id="..category_id)
		return category:getChildCategoryBoothsByName(classification_name)
end)



---------------------------新闻列表（单个栏目新闻）
--新闻列表，单个栏目新闻，按照新闻的publish_time搜索
app:get("/booths/api/v1/classifications/:classification_id/contents",function(self)
	local classification_id = self.params.classification_id
	local map_id = self.params.sequence
	local limit = self.params.limit
	return content_column_mapping:getNewsByColumnBooths(classification_id,map_id, limit)

	
end)

--新闻搜索,标题首字母
app:get("/booths/api/v1/contents",function(self) 
	local keyword = self.params.keyword
	if keyword==nil then
		keyword=""
	end
	local publish_time = self.params.publish_time
	local limit = self.params.limit
	return  content:searchByKeywordBooths(keyword, publish_time, limit)


end)


return app
