local content_column_mapping = {}


local ContentColumnMappings = require ("models.content_column_mappings")

local response_body = require("utils.response_body")
local area_convert = require("dtos.area_convert")

content_column_mapping.successMess="执行成功"


--根据栏目，城市获取新闻列表


function content_column_mapping:getNewsByAreaAndColumn(area, category_id, map_id, limit)

	local content_column_mappings = ContentColumnMappings:getNewsByAreaAndColumn(area, category_id, map_id, limit_num)
	local newsDtos = {}
	for k, v in ipairs(content_column_mappings) do
		local newsDto = area_convert:convertNews2NewsDto(v:get_content())
		--local newsDto = v:get_content()
		newsDtos[k] = newsDto
	end  
	return {json = response_body.build(200,content_column_mapping.successMess,{news = newsDtos })}

end


--根据单个栏目获取新闻列表,按照新闻的publishtime搜索
function content_column_mapping:getNewsByColumn(category_id,map_id,limit)
	local content_column_mappings = ContentColumnMappings:getNewsByColumn(category_id, map_id, limit)
	local newsDtos = {}
	for k, v in ipairs(content_column_mappings) do
		local newsDto = area_convert:convertNews2NewsDto(v:get_content())
		--local newsDto = v:get_content()
		newsDtos[k] = newsDto
	end  
	
	return {json = response_body.build(200,content_column_mapping.successMess,{news = newsDtos })}
	

end

--通过栏目获取新闻，按照publish_date分页排序
function  content_column_mapping:newsByCategoryAndPublishDate(category_id, publish_date,limit)
	local  content_column_mappings =  ContentColumnMappings:newsByCategoryAndPublishDate(category_id, publish_date, limit)
	local newsDtos = {}
	for k, v in ipairs(content_column_mappings) do
		local newsDto = area_convert:convertNews2NewsDto(v:get_content())
		newsDtos[k] = newsDto
	end  
	
	return {json = response_body.build(200,content_column_mapping.successMess,{news = newsDtos })}

end

--新闻列表
function  content_column_mapping:getNewsByColumnOrderBySequence(category_id,map_id, limit)
	local content_column_mappings = ContentColumnMappings:getNewsByColumnOrderBySequence(category_id, map_id, limit)
	local newsDtos = {}
	for k, v in ipairs(content_column_mappings) do
		local newsDto = area_convert:convertNews2NewsDto(v:get_content())
		--local newsDto = v:get_content()
		newsDtos[k] = newsDto
	end  
	return {json = response_body.build(200,content_column_mapping.successMess,{news = newsDtos })}
end





--根据单个栏目获取新闻列表,按照新闻的publishtime搜索
function content_column_mapping:getNewsByColumnBooths(category_id,map_id,limit)
	local content_column_mappings = ContentColumnMappings:getNewsByColumn(category_id, map_id, limit)
	local newsDtos = {}
	for k, v in ipairs(content_column_mappings) do
		local newsDto = area_convert:convertNews2NewsDtoBooths(v:get_content())
		newsDtos[k] = newsDto
	end  
	
	return {json = response_body.build(100000,content_column_mapping.successMess,{contents = newsDtos })}
	

end


return content_column_mapping