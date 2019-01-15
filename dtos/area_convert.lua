area_convert = {}

local cjson = require("cjson")
local convert = require("dtos.convert")
local os = require('os')
function area_convert:convertAreaToAreaDto(area)
	local areaDto = {}
	if area~= nil then
		areaDto["id"]=area["id"]
		areaDto["name"]=area["name"]
	end
	
	return areaDto 

end

function  area_convert:convertNews2NewsDto(news)
		local newsDto = {}
		newsDto["id"]=news["id"]
		newsDto["title"]=news["title"]
		newsDto["title_abbr"]=news["title_abbr"]
		--海报
		newsDto["post1"] =""
		newsDto["post2"] = ""
		newsDto["post3"] = ""
		newsDto["post4"] = ""
		local  posterDtos = {}

		local posters= news["posters"]
		if posters==nil then
			newsDto["cover"]={}
		else 
			local posters = cjson.decode(posters)
			--print("数据类型="..type(posters))
			--newsDto["cover"] =posters
			for k, v in pairs(posters) do
				--print("内部值为=="..v["targetUrl"])
				local targetUrl = v["targetUrl"]
				posterDtos[k] = targetUrl
			end 


		end
		local j = 1
		for k, v in pairs(posterDtos) do
			--print("内部k="..k..";url="..v)
			if k=="001" then
				newsDto["post1"]=v
			elseif k=="002" then
				newsDto["post2"]=v
			elseif k=="003" then
				newsDto["post3"]=v
			elseif k=="004" then
				newsDto["post4"]=v
			end
			--if j==1 then
				--newsDto["post1"]=v
			--elseif j==2 then
			--	newsDto["post2"]=v
			--elseif j==3 then
			--	newsDto["post3"]=v
			--elseif j==4 then
			--	newsDto["post4"]=v
			--end
			--j = j+1 
		end

		newsDto["map_id"]=news["id"]
		newsDto["publish_time"]=GetTimeByTime(news["publish_time"])
	 	newsDto["publish_date"]=GetTimeByDate(news["publish_time"])
		
		newsDto["source"] = ""
		local areas = news:get_areas()
		local areasDtos = {nil}
		for k, v in pairs(areas) do
			local area = v:get_area();
			areasDtos[k] = area["name"]
		end
		newsDto["area"] = areasDtos
		newsDto["weight"] = 0

		--获取客户
		local  customer = os.getenv("CUSTOMER")    
		--获取地区
		local  area = os.getenv("AREA")
		if customer == "qian" and area == "qian" then   -----------------贵州的获取videoid
			local videos = news["videos"]

			if videos == nil then
				newsDto["url"] = {}
			else
				--print("视频"..news["videos"])
				local url_videos = cjson.decode(news["videos"])
				local origin= url_videos["origin"]
				local local_cdnurl =""
				if origin~=nil then
					local cdnUrl =  origin["cdnUrl"]	
					if cdnUrl ~=nil then
						local_cdnurl = cdnUrl
					end
				end
				newsDto["url"] = local_cdnurl
				
			end
		elseif customer == "wangbo" and area == "qian" then-----------------------网博
			newsDto["url"] = news["id"] 
		end

		print("get  the  url=============================whlwhlwhwlhl============================="..newsDto["url"])

		local type = news["type"]
		newsDto["hasSubject"] = false
		newsDto["element_type"] = 1
		local subject = ""
		if type == 2 then
			newsDto["hasSubject"] = true  --专题
			newsDto["element_type"] = 3   --专题
			subject = news["title"]
		else
			local subjects = news:get_content_subject_mapping();
			for k,v in pairs(subjects) do
				local content = v:get_content() 
				subject=content["title"]..","..subject
				subject=string.sub(subject,0,string.len(subject)-1)
			end
		end
		
		newsDto["subject"] = subject
		local content_mappings = news:get_content_mapping();
		newsDto["totalCount"] =table.maxn(content_mappings)
	
		newsDto["thumbnail"] = ""
		newsDto["playCount"] = 0
		local news_tags = news["tags"]
		if news_tags~=nil and news_tags~="" then
			
			newsDto["keyword"] = cjson.decode(news["tags"])
		else
			newsDto["keyword"] = {}
		end
		
		--newsDto["keyword"] = {"哈哈哈哈"}
		
		return newsDto

end



---- 通过日期获取秒 yyyy-MM-dd HH:mm:ss
function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
     table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function GetTimeByDateTime(r)
	if r==nil then
		return 0
	else 
		
		local a = split(r," ")
	    local b = split(a[1], "-")
	    local c = split(a[2], ":")
	    local t = os.time({year=b[1],month=b[2],day=b[3], hour=c[1], min=c[2], sec=c[3]}) * 1000
	    
	    return t
	end
    
end



function GetTimeByDate(r)
	if r==nil then
		return 0
	else 
		
		
	   local a = split(r," ")
	    local b = split(a[1], "-")
	    local c = split(a[2], ":")
	 
	      local t = os.time({year=b[1],month=b[2],day=b[3], hour=0, min=0, sec=0}) * 1000
	    
	    return t
	end
    
end


function GetTimeByTime(r)
	if r==nil then
		return 0
	else 
	    local t = GetTimeByDateTime(r) -GetTimeByDate(r)
	    
	    return t
	end
    
end


function  area_convert:convertNews2NewsDtoBooths(news)
		local newsDto = {}
		newsDto["id"]=news["id"]
		newsDto["title"]=news["title"]
		newsDto["title_abbr"]=news["title_abbr"]
		--海报
		local newsDto_post1 =nil
		local newsDto_post2  = nil
		local newsDto_post3  = nil
		local newsDto_post4 = nil
		local  posterDtos = {}

		local posters= news["posters"]
		if posters==nil then
			newsDto["cover"]={}
		else 
			local posters = cjson.decode(posters)
			--print("数据类型="..type(posters))
			--newsDto["cover"] =posters
			for k, v in pairs(posters) do
				--print("内部值为=="..v["targetUrl"])
				local targetUrl = v
				posterDtos[k] = targetUrl
			end 


		end
		local j = 1
		for k, v in pairs(posterDtos) do
			--print("内部k="..k..";url="..v)
			if k=="001" then
				 newsDto_post1 ={}
				 newsDto_post1["url"] =v["targetUrl"]
				 newsDto_post1["width"] =v["width"]
				 newsDto_post1["height"] =v["height"]
				 newsDto_post1["position"] =1
				 newsDto_post1["id"] =1
			elseif k=="002" then
				  newsDto_post2 ={}
				 newsDto_post2["url"] =v["targetUrl"]
				 newsDto_post2["width"] =v["width"]
				 newsDto_post2["height"] =v["height"]
				 newsDto_post2["position"] =2
				 newsDto_post2["id"] =2
			elseif k=="003" then
				 newsDto_post3 ={}
				 newsDto_post3["url"]=v["targetUrl"]
				 newsDto_post3["width"] =v["width"]
				 newsDto_post3["height"] =v["height"]
				 newsDto_post3["position"] =3
				 newsDto_post3["id"] =3
			elseif k=="004" then
				 newsDto_post4 ={}
				 newsDto_post4["url"] =v["targetUrl"]
				 newsDto_post4["width"] =v["width"]
				 newsDto_post4["height"] =v["height"]
				 newsDto_post4["position"] =4
				 newsDto_post4["id"] =4
			end
			
		end

		newsDto["sequence"]=news["id"]
		newsDto["publish_time"]=news["publish_time"]
	 	-- newsDto["publish_date"]=GetTimeByDate(news["publish_time"])
		
		newsDto["source"] = ""
		-- local areas = news:get_areas()
		-- local areasDtos = {nil}
		-- for k, v in pairs(areas) do
		-- 	local area = v:get_area();
		-- 	areasDtos[k] = area["name"]
		-- end
		-- newsDto["area"] = areasDtos
		-- newsDto["weight"] = 0

		--获取客户
		local  customer = os.getenv("CUSTOMER")    
		--获取地区
		local  area = os.getenv("AREA")
		local newsDto_url = nil
		if customer == "qian" and area == "qian" then   -----------------贵州的获取videoid
			local videos = news["videos"]
			
			if videos == nil then
				newsDto_url = {}
			else
				--print("视频"..news["videos"])
				local url_videos = cjson.decode(news["videos"])
				local origin= url_videos["origin"]
				local local_cdnurl =""
				if origin~=nil then
					local cdnUrl =  origin["cdnUrl"]	
					if cdnUrl ~=nil then
						local_cdnurl = cdnUrl
					end
				end
				newsDto_url={}
				newsDto_url["url_key"] = local_cdnurl
				newsDto_url["cdn_key"] = local_cdnurl
				newsDto_url["id"] = news["id"]
				newsDto_url["type"] =1
				newsDto_url["size"] =0
			end
		elseif customer == "wangbo" and area == "qian" then-----------------------网博
			newsDto_url = {}
			newsDto_url["url_key"] = news["id"] 
			newsDto_url["cdn_key"] = news["id"] 
			newsDto_url["id"] = news["id"]
			newsDto_url["type"] =1
			newsDto_url["size"] =0
		end

		

		-- local type = news["type"]
		-- newsDto["hasSubject"] = false
		-- newsDto["element_type"] = 1
		-- local subject = ""
		-- if type == 2 then
		-- 	newsDto["hasSubject"] = true  --专题
		-- 	newsDto["element_type"] = 3   --专题
		-- 	subject = news["title"]
		-- else
		-- 	local subjects = news:get_content_subject_mapping();
		-- 	for k,v in pairs(subjects) do
		-- 		local content = v:get_content() 
		-- 		subject=content["title"]..","..subject
		-- 		subject=string.sub(subject,0,string.len(subject)-1)
		-- 	end
		-- end
		
		-- newsDto["subject"] = subject
		-- local content_mappings = news:get_content_mapping();
		-- newsDto["totalCount"] =table.maxn(content_mappings)
	
		-- newsDto["thumbnail"] = ""
		newsDto["playCount"] = 0
		-- local news_tags = news["tags"]
		-- if news_tags~=nil and news_tags~="" then
			
		-- 	newsDto["keyword"] = cjson.decode(news["tags"])
		-- else
		-- 	newsDto["keyword"] = {}
		-- end
		
		newsDto["posters"] = {}
		table.insert(newsDto["posters"], newsDto_post1)
		table.insert(newsDto["posters"], newsDto_post2)
		table.insert(newsDto["posters"], newsDto_post3)
		table.insert(newsDto["posters"], newsDto_post4)

		newsDto["medias"] = {}
		table.insert(newsDto["medias"],newsDto_url)
		newsDto["asset_id"] =news["uuid"]
		newsDto["type"] = news["type"]
		newsDto["description"] = news["description"]
		local durationVal=news["duration"]
		if durationVal==nil then
			durationVal=0
		end
		newsDto["duration"] =  durationVal*1000
		return newsDto

end

return area_convert