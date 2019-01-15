es_convert = {}

local cjson = require("cjson")
cjson.encode_empty_table_as_object(false)
local convert = require("dtos.convert")
local os = require('os')


function  es_convert:convertNews2NewsDto(news)
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
		newsDto["cover"]={}
		if posters==nil then
			
		else 
			local posters = news["posters"]
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
			--	newsDto["post1"]=v
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
		local areas = news["areas"]
		local areasDtos = {nil}
		if areas ~=nil then 
			for k, v in ipairs(areas) do
			
				areasDtos[k] = v
			end
		end
		newsDto["area"] = areasDtos
		newsDto["weight"] = 0
		newsDto["url"] = ""
		--local videos = news["videos"]

		--if videos ~= nil then
			--print("视频"..news["videos"])
		--	local url_videos = news["videos"]
		--	local origin= url_videos["origin"]
		--	local url =nil
		--	if origin~=nil then
		--		url= origin["targetUrl"]
		--	end
		--	newsDto["url"] = url		
	--	end
		--因为要换串

		--区分地区和customer--begin
			--获取客户
		local  customer = os.getenv("CUSTOMER")    
		--获取地区
		local  area = os.getenv("AREA")
		if customer == "qian" and area == "qian" then   -----------------贵州的获取videoid

			local videos = news["videos"]

			if videos ~= nil then
				--print("视频"..news["videos"])
				local url_videos = news["videos"]
				local origin= url_videos["origin"]
				local url =nil
				if origin~=nil then
					url= origin["cdnUrl"]
				end
				newsDto["url"] = url		
			end
			
		elseif customer == "wangbo" and area == "qian" then-----------------------网博
			newsDto["url"]= news["id"]
		end
		--区分地区和custoerm--end



		--newsDto["url"]= news["id"]

		local type = news["type"]
		newsDto["hasSubject"] = false
		newsDto["element_type"] = 1
		local subject = ""
		if type == 2 then
			newsDto["hasSubject"] = true  --专题
			newsDto["element_type"] = 3   --专题
			subject = news["title"]
		else
			--local subjects = news:get_content_subject_mapping();
			--for k,v in pairs(subjects) do
			--	local content = v:get_content() 
			--	subject=content["title"]..","..subject
			--	subject=string.sub(subject,0,string.len(subject)-1)
			--end
		end
		
		newsDto["subject"] = subject
		--local content_mappings = news:get_content_mapping();
		--newsDto["totalCount"] =table.maxn(content_mappings)
	
		newsDto["thumbnail"] = ""
		newsDto["playCount"] = 0
		local news_tags = news["tags"]
		if news_tags~=nil then
			newsDto["keyword"] = news_tags
		else
			newsDto["keyword"] = {}
		end
		
		
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


return es_convert