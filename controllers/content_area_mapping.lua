local content_area_mapping = {}

local ContentAreaMappings = require ("models.content_area_mappings")
local cjson = require("cjson")
local response_body = require("utils.response_body")
local area_convert = require("dtos.area_convert")

content_area_mapping.successMess="执行成功"

--根据地区获取新闻列表
function content_area_mapping:getNewsByArea(area, map_id, limit)

	
	local content_mappings = ContentAreaMappings:getContentsByArea(area, map_id, limit)
	local newsDtos = {}
	for k, v in ipairs(content_mappings) do
		local newsDto = area_convert:convertNews2NewsDto(v:get_content())
		--local newsDto = v:get_content()
		newsDtos[k] = newsDto
	end  
	return {json = response_body.build(200,content_area_mapping.successMess,{news = newsDtos })}

end

return content_area_mapping