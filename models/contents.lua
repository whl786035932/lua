local trim     = require("lapis.util").trim_filter
local Model    = require("lapis.db.model").Model
local Contents    = Model:extend("content", {
  primary_key = "id",
  relations = {
    {"content_area_mapping",has_many = "ContentAreaMappings", key = "content_id"},
    
    {"areas", has_many = "ContentAreaMappings",key="area_id"},
    {"content_mapping", has_many = "ContentMappings",key="content_id"},
    {"content_subject_mapping", has_many = "ContentMappings",key="video_id"}
  }
})

function Contents:get(id)
	return unpack(self:select("where id=? limit 1", id))
end

--- Get all users
-- @treturn table users List of users
function Contents:list()
	return self:select("order by createtime desc")
end

--新闻搜索，按照标题首字母
function Contents:searchByKeyword(keyword, map_id, limit)
	if limit==nil then
		limit = 20	
	end
	local sql=""
	if map_id==nil then
		sql="where title_abbr like ".."'%"..keyword.."%' and shelve_status=1 and isabled=0  order by id desc limit "..tonumber(limit)
	else
		sql ="where title_abbr like ".."'%"..keyword.."%' and  id<"..tonumber(map_id).."  and shelve_status=1  and isabled=0   order by id desc limit "..tonumber(limit)
	end
	print("sql语句="..sql)

	local content_column_mappings = Contents:select(sql)
	
	return content_column_mappings
	

end

--搜索推荐
function  Contents:getRecommendContents(limit)
	if limit==nil then
		limit = 20	
	end
	
	local contents = Contents:select(" where shelve_status =1 and isabled=0  order by id desc limit ?", tonumber(limit))
	
	return contents
end

--获取视频的url，根据视频的id
function Contents:getUrlAccordingToId(id)
	--根据用户的id获取用户的订阅号
	local videos = Contents:select("where id=? limit 1",tonumber(id),{fields="videos"})
	if #videos>0 then
		return videos[1]
	end
	return videos
end


--新闻搜索，按照标题首字母
function Contents:searchByKeywordBooths(keyword, publish_time, limit)
	if limit==nil then
		limit = 20	
	end
	local sql=""
	if publish_time==nil then
		sql="where title_abbr like ".."'%"..keyword.."%' and shelve_status=1 and isabled=0  order by publish_time desc limit "..tonumber(limit)
	else
		sql ="where title_abbr like ".."'%"..keyword.."%' and  publish_time< '"..publish_time.."'  and shelve_status=1  and isabled=0   order by publish_time desc limit "..tonumber(limit)
	end
	print("sql1111111111111111111111语句="..sql)

	local content_column_mappings = Contents:select(sql)
	
	return content_column_mappings
	

end

return Contents