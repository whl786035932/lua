search_es = {}
local printTable = require "utils.print_table"
local sys_config = require("controllers.sys_config")
local UserSubs = require("models.userSubs")
local http = require "resty.http" 
local httpc = http:new()
local cjson = require("cjson")
local es_convert = require("dtos.es_convert")
search_es.successMess = "执行成功"
local response_body = require("utils.response_body")

--调用cimp的搜索引擎接口
function search_es:search_user_recommend(userId, size, from,filterIds)

	--获取用户的订阅的标签
	local  subTags = ""
	local subTagsTab = UserSubs:getUserSubs(userId)  --值为：订阅号1， 订阅号2
	local subMatchTab = UserSubs:getUserMatchWord(userId)
	if subTagsTab~=nil and subTagsTab["subword"] ~=nil then
		--print("获取到的用户的订阅====================="..subTagsTab["subword"])
		subTags=subTagsTab["subword"]
	elseif subMatchTab~=nil and subMatchTab["machword"] ~=nil then
		
		subTags=subMatchTab["machword"]
		
	end


	-- if subMatchTab~=nil and subMatchTab["machword"] ~=nil then
	-- 	if subTags~="" then
	-- 		subTags=subTags..","..subMatchTab["machword"]
	-- 	else 
	-- 		subTags=subTags..subMatchTab["machword"]
	-- 	end
	-- end
	--print("用户的机器加自己的订阅词$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$="..subTags)
	
	
	--判读是否为空，如果么有订阅
	local newsDtos = {}
	local hits_hits = search_es:searchAccordingTag(subTags, size,from,filterIds)

	if hits_hits ~=nil and #hits_hits>0 then
		

		for k,v in ipairs(hits_hits) do
			local newsDto = es_convert:convertNews2NewsDto(v._source)
			newsDtos[k]= newsDto
		end

	else 
		--热频率词汇
		local hot_words =  search_es:hotWord(9)
		--printTable:print_r(hot_words)
		local hotWordStr = ""
		for k, v in ipairs(hot_words) do
			hotWordStr=hotWordStr..v["key"]..","
		end
		print("拼接的热搜词汇="..hotWordStr)
		--然后调用搜索接口，开始搜索begin
		local hits_hits_again = search_es:searchAccordingTag(hotWordStr, size,from,filterIds)
		--print("进入到循环中.."..#hits_hits_again)
		if hits_hits_again ~=nil then
			for k,v in ipairs(hits_hits_again) do

				local newsDto = es_convert:convertNews2NewsDto(v._source)
				newsDtos[k]= newsDto
			end
		end
		--搜索end

	end
	
	
	return {json = response_body.build(200,search_es.successMess,{news =  newsDtos})}
end

--根据标签进行搜索，调用ES
function search_es:searchAccordingTag(subTags, size, from,filterIds)
	--开始组装query结构
	local  esRequestBody = {}
	if subTags==nil then
		subTags=""
	end
	

	--判断是否有订阅
	
		local  query = {}

		local bool={}
		

		local  match = {}
		local must_match={}
		match["tags"] = subTags
		must_match["match"]=match
		
		

		--组织must

		local must={}
		--must的match
		must[1]=must_match
		--must_term
		local term={}
		local must_term={}
		term["shelveStatus"]=1
		must_term["term"]=term
		must[2]=must_term


		bool["must"]=must



		local must_not={}
		if filterIds ~=nil and #filterIds>0 then
			
			for k,v in ipairs(filterIds) do
				local must_innernot_term1={}
				must_innernot_term1["_id"]=v
				local must_not_term1={}
				must_not_term1["term"]=must_innernot_term1
				must_not[k]=must_not_term1
		    end
		end
		bool["must_not"]=must_not
		




		
		query["bool"]= bool


		esRequestBody["query"] = query
	
	

	

	local sort = {}
	local order = {}
	order["order"] = "desc"
	sort["completeTime"] = order 
	esRequestBody["sort"] =  sort


	esRequestBody["size"] = tonumber(size)
	esRequestBody["from"] = tonumber(from)

	print("发送的body=================================begin===================")
	printTable:print_r(esRequestBody)
	print("发送的body=================================end===================")
	--先获取es的地址
	local  esIpPort = sys_config:elSearchUrl()
	
	local  esRecommendUrl = esIpPort.."cimp/video/_search"
	--print("获取到的系统配置的搜索引擎地址="..esRecommendUrl)

	--在请求body
	local raw_data = string.rep(cjson.encode(esRequestBody), 1)
	--print ("发送的body="..raw_data)
    local chunked = {
                    string.format("%x", #raw_data),
                    "\r\n",
                    raw_data,
                    "\r\n",
                    "0\r\n\r\n",
    }

	--end

	local res, err = httpc:request_uri(esRecommendUrl, {
	method = "POST",
	body = chunked,
	headers = {
		 ["User-Agent"] = "lua-resty-http",
		 ["Transfer-Encoding"] = "chunked"
	 }
	})
	--print("获取到的值    ============================")

	--printTable:print_r(res)

	
	local body = cjson.decode(res.body)
	
	--printTable:print_r(body.hits)
	local hits_hits = body.hits.hits


	return hits_hits
end



--调用ES的热频词汇
function search_es:hotWord( size)
	--开始组装query结构
	local  esRequestBody = {}
	local aggs = {}
	local titles = {}
	local terms =  {}
	terms["field"] = "all_word"
	terms["size"] =  size
	titles["terms"] = terms
	aggs["titles"] = titles
	esRequestBody["aggs"] = aggs
	esRequestBody["size"] = 0


	
	

	--print("发送的热搜词的body=================================begin===================")
	--:print_r(esRequestBody)
	--print("发送的热搜词的body=================================end===================")
	--先获取es的地址
	local  esIpPort = sys_config:elSearchUrl()
	
	local  esRecommendUrl = esIpPort.."cimp/video/_search"
	--print("获取到的系统配置的搜索引擎地址="..esRecommendUrl)

	--在请求body
	local raw_data = string.rep(cjson.encode(esRequestBody), 512)
    local chunked = {
                    string.format("%x", #raw_data),
                    "\r\n",
                    raw_data,
                    "\r\n",
                    "0\r\n\r\n",
    }

	--end

	local res, err = httpc:request_uri(esRecommendUrl, {
	method = "POST",
	body = chunked,
	headers = {
		 ["User-Agent"] = "lua-resty-http",
		 ["Transfer-Encoding"] = "chunked"
	 }
	})
	print("获取到的值    ============================")

	--printTable:print_r(res)

	
	local body = cjson.decode(res.body)
	
	
	local body_aggresgations_titles_buckets = body.aggregations.titles.buckets


	return body_aggresgations_titles_buckets
end

return search_es