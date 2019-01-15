local  content_mapping = {}

local ContentMappings = require ("models.content_mappings")
local cjson = require("cjson")
local response_body = require("utils.response_body")
local area_convert = require("dtos.area_convert")

content_mapping.successMess="执行成功"

--获取专题列表

function   content_mapping:getNewsBySubject(subject_id, map_id, limit)
	local content_mappings = ContentMappings:getNewsByAreaAndColumn(subject_id, map_id, limit)
	local newsDtos = {}
	for k, v in ipairs(content_mappings) do
		local newsDto = area_convert:convertNews2NewsDto(v:get_video())
		--local newsDto = v:get_content()
		newsDtos[k] = newsDto
	end  
	return {json = response_body.build(200,content_mapping.successMess,{news = newsDtos })}

end

return content_mapping