ContentController = {}
local Contents        = require "models.contents"
local ResponseBody = require "utils.response_body"
local ContentDetailDto = require "dtos.content_detail_dto"
local PrintTable = require "utils.print_table"


function ContentController:list()
	return { json = Contents:list() }
end

function ContentController:get(id)
	content = Contents:get(id)
	-- PrintTable:print_r(content)
	-- PrintTable:print_r(content:get_content_subject_mapping())
	if not content then
		return { json =  ResponseBody.build(404,"不存在",{})}
	else
		return { json =  ResponseBody.build(200,"执行成功",{newsinfo = ContentDetailDto:build(content)})}
	end
end



---根据标题首字母搜索新闻， write by whl
function ContentController:searchByKeyword(keyword, map_id, limit)
		local contents = Contents:searchByKeyword(keyword, map_id, limit)
		local contentDtos = {}
		for k, v in ipairs(contents) do
			local contentDto =  area_convert:convertNews2NewsDto(v)
			contentDtos[k] = contentDto
		end
		return {json = ResponseBody.build(200,"执行成功",{news =contentDtos})}

end

--搜索推荐
function  ContentController:getRecommendContents(limit)
	local contents = Contents:getRecommendContents(limit)
	local contentDtos = {}
	for k, v in ipairs(contents) do
			local contentDto =  area_convert:convertNews2NewsDto(v)
			contentDtos[k] = contentDto
	end
	return {json = ResponseBody.build(200,"执行成功",{recommends =contentDtos})}
end


---根据标题首字母搜索新闻， write by whl
function ContentController:searchByKeywordBooths(keyword, publish_time, limit)
		local contents = Contents:searchByKeywordBooths(keyword, publish_time, limit)
		local contentDtos = {}
		for k, v in ipairs(contents) do
			local contentDto =  area_convert:convertNews2NewsDtoBooths(v)
			contentDtos[k] = contentDto
		end
		return {json = ResponseBody.build(100000,"执行成功",{contents =contentDtos})}

end

return ContentController
