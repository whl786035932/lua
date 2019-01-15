local Model =  require("lapis.db.model").Model
local Contents = require("models.contents")
local ContentMappings = Model:extend("content_mapping",{
	relations ={
		{"content",belongs_to = "Contents", key = "content_id"},
		{"video", belongs_to = "Contents", key = "video_id"}
	}

})


function ContentMappings:getNewsByAreaAndColumn(subject_id, map_id, limit)
	-- SELECT cm.*,video.title,video.publish_time from `content_mapping`  as cm left join content as c on cm.content_id=c.id left join  content as video on cm.video_id = video.id  where cm.content_id=142   and video.shelve_status=1    order by sequence is null , sequence asc ,  video.publish_time is null ,video.publish_time desc;
	if limit==nil then
		limit = 20	
	end
	local sql=""
	if map_id==nil then
		sql=" as cm left join content as c on cm.content_id=c.id left join  content as video on cm.video_id = video.id  where cm.content_id="..subject_id.."   and video.shelve_status=1   and video.isabled=0  order by sequence is null , sequence asc , video.id desc " 
	else
		sql =" as cm left join content as c on cm.content_id=c.id  left join  content as video on cm.video_id = video.id where cm.content_id="..subject_id.."and video.id<"..tonumber(map_id).."   and video.shelve_status=1 and  video.isabled=0  order by  sequence is null , sequence asc,  video.id desc"
	end
	print("sql语句="..sql)

	local content_mappings = ContentMappings:select(sql)
	
	return content_mappings

end

return ContentMappings
