local Model =  require("lapis.db.model").Model
local db = require("lapis.db")
local  Areas = require("models.areas")
local Contents = require("models.contents")

local ContentAreaMappings = Model:extend("content_area_mapping",{
	relations ={
		{"area",belongs_to = "Areas", key = "area_id"},
		{"content", belongs_to = "Contents", key = "content_id"}
	}

})


--get area according area_code
function ContentAreaMappings:getContentsByArea(area, map_id, limit)
	
	
	if limit==nil then
		limit = 20
	end
	--local content_area_mappings = ContentAreaMappings:select(" where content_id < ?  order by content_id desc  limit ?", map_id, limit )
	--local content_area_mappings = db.query("select * from  content_area_mapping as ca left join content as c on ca.content_id=c.id left join area as a on ca.area_id=a.id where  a.name like ".. "'%"..area.."%'".."  and c.id <   "..map_id.."   order by ca.content_id  desc limit  "..limit    )
	local sql = ""
	if map_id==nil then
		sql=" as ca left join content as c on ca.content_id=c.id left join area as a on ca.area_id=a.id where  a.name like ".. "'%"..area.."%'".."  and c.shelve_status=1  and  c.isabled=0   order by ca.content_id  desc limit  "..tonumber(limit)
	else
		sql =" as ca left join content as c on ca.content_id=c.id left join area as a on ca.area_id=a.id where  a.name like ".. "'%"..area.."%'".."  and c.id <   "..tonumber(map_id).."  and c.shelve_status=1  and c.isabled=0 order by ca.content_id  desc limit  "..tonumber(limit);
	end
	
	--local content_area_mappings = ContentAreaMappings:select(" as ca left join content as c on ca.content_id=c.id left join area as a on ca.area_id=a.id where  a.name like ".. "'%"..area.."%'".."  and c.id <   "..map_id.."   order by ca.content_id  desc limit  "..limit )
	local content_area_mappings = ContentAreaMappings:select(sql)
	
	return content_area_mappings
	
end


--

return ContentAreaMappings