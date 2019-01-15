local date_util = require("utils.date_util")
local convert = require("dtos.convert")
ContentDetailDto = {}

function ContentDetailDto:build(content)
	dto = {}
	dto["id"] = content.id
	dto["title"] = content.title
	dto["title_abbr"] = content.title_abbr
	if content.type == 1 then
		dto["element_type"] = 1
	elseif content.type == 2 then
		dto["element_type"] = 3
	else
		dto["element_type"] = -1
	end
	
	dto["map_id"] = content.id
	dto["length"] = content.duration
	dto["publish_date"] = date_util.getDateLong(content.publish_time)
	dto["publish_time"] = date_util.getTimeLong(content.publish_time)

	local areas = {}
	for k, v in pairs(content:get_content_area_mapping()) do
	    areas[k] = v:get_area().name
	end
	dto["area"] = areas

	dto["url"] = convert.getUrl(content)
	dto["cover"] = ""
	dto["thumbnail"] = ""
	dto["description"] = content.description

	local subjects = {}
	for k, v in pairs(content:get_content_subject_mapping()) do
	    subjects[k] = v:get_content().id
	end
	dto["subject"] = subjects

	dto["inserted_at"] = content.createtime
	dto["updated_at"] = content.updatetime

	return dto
end

return ContentDetailDto