local Model =  require("lapis.db.model").Model
local db = require("lapis.db")
local  Areas = require("models.areas")
local Contents = require("models.contents")
local Categorys = require("models.categorys")
local ContentColumnMappings = Model:extend("content_column_mapping",{
	relations ={
		{"column",belongs_to = "Categorys", key = "column_id"},
		{"content", belongs_to = "Contents", key = "content_id"}
	}

})


--get area according area_code
function ContentColumnMappings:getNewsByAreaAndColumn(area,category_id,  map_id, limit)
	
	if limit==nil then
		limit = 20	
	end
	local sql=""
	if map_id==nil then
		sql=" as co_cl left join content as c on co_cl.content_id=c.id left join content_area_mapping as ca on ca.content_id=c.id  left join area as a on ca.area_id=a.id where co_cl.column_id=".. category_id.." and  a.name like ".. "'%"..area.."%'".."   order by co_cl.content_id  desc  limit  "..tonumber(limit) 
	else
		sql =" as co_cl left join content as c on co_cl.content_id=c.id  left join content_area_mapping as ca on ca.content_id=c.id  left join area as a on ca.area_id=a.id where co_cl.column_id=".. category_id.." and  a.name like ".. "'%"..area.."%'".."  and c.id <   "..tonumber(map_id).."   order by co_cl.content_id  desc limit  "..tonumber(limit) 
	end
	print("sql语句="..sql)

	local content_column_mappings = ContentColumnMappings:select(sql)
	
	return content_column_mappings
	
end


--根据单个栏目获取新闻列表,按照publishtime排序
function ContentColumnMappings:getNewsByColumn(category_id, map_id, limit)
	if limit==nil then
		limit=20
	end

	local content_column_mappings = nil
	if map_id==nil then
		content_column_mappings=ContentColumnMappings:select(" as cont_cl  left join content as c on cont_cl.content_id= c.id  where column_id=? and c.shelve_status=1 and (sequence=0 or sequence is null) and  c.isabled=0 order by c.id desc  limit ?",category_id, tonumber(limit))
	else 
		content_column_mappings=ContentColumnMappings:select(" as cont_cl  left join content as c on cont_cl.content_id= c.id where column_id=? and  c.id<? and c.shelve_status=1  and (sequence=0 or sequence is null ) and  c.isabled=0  order by c.id desc  limit ?",category_id,tonumber(map_id), tonumber(limit))
	end
	return content_column_mappings

end

--通过栏目获取新闻，按照publish_date分页+排序
function ContentColumnMappings:newsByCategoryAndPublishDate(category_id, publish_date,limit)
	if limit==nil then
		limit=20
	end

	local content_column_mappings = nil
	if publish_date==nil then
		content_column_mappings=ContentColumnMappings:select(" as cont_cl  left join content as c on cont_cl.content_id= c.id  where column_id=? and c.shelve_status=1  and  c.isabled=0  order by c.publish_time desc  limit ?",category_id, tonumber(limit))
	else 
		content_column_mappings=ContentColumnMappings:select(" as cont_cl  left join content as c on cont_cl.content_id= c.id where column_id=? and  c.publish_time<? and c.shelve_status=1  and  c.isabled=0  order by c.publish_time desc  limit ?",category_id,publish_date, tonumber(limit))
	end
	return content_column_mappings
end

--新闻列表(栏目推荐新闻),按照sequence asc 排序
function ContentColumnMappings:getNewsByColumnOrderBySequence(category_id, map_id, limit)

	
	if limit==nil then
		limit=20
	end

	local content_column_mappings = nil
	if map_id==nil then
		
		--content_column_mappings=ContentColumnMappings:select(" as cont_cl  left join content as c on cont_cl.content_id= c.id where column_id=?  and c.shelve_status=1  order by sequence asc, c.publish_time desc  limit ?",category_id, tonumber(limit))
		--content_column_mappings=ContentColumnMappings:select(" as cont_cl  left join content as c on cont_cl.content_id= c.id  where column_id=? and c.shelve_status=1   order by sequencenull asc , publish_timenull desc limit ?",category_id, tonumber(limit),{fields="cont_cl.*, sequence is null as sequencenull, c.publish_time is null as publish_timenull"})
		content_column_mappings=ContentColumnMappings:select(" as cont_cl  left join content as c on cont_cl.content_id= c.id where column_id=?  and c.shelve_status=1  and  c.isabled=0 order by sequence is null , sequence asc, c.id desc  limit ?",category_id, tonumber(limit))
		
	else 
		--content_column_mappings=ContentColumnMappings:select(" as cont_cl  left join content as c on cont_cl.content_id= c.id where column_id=? and  sequence<? and c.shelve_status=1  order by sequence asc, c.publish_time desc  limit ?",category_id,map_id, tonumber(limit))
		--content_column_mappings=ContentColumnMappings:select(" as cont_cl  left join content as c on cont_cl.content_id= c.id where column_id=? and  sequence<? and c.shelve_status=1  order by sequencenull asc, publish_timenull desc  limit ?",category_id, tonumber(map_id), tonumber(limit),{fields="cont_cl.*, sequence is null as sequencenull, c.publish_time is null as publish_timenull"})
		content_column_mappings=ContentColumnMappings:select(" as cont_cl  left join content as c on cont_cl.content_id= c.id where column_id=? and  sequence<? and c.shelve_status=1 and  c.isabled=0  order by sequence is null ,sequence asc, c.publish_time is null , c.publish_time desc  limit ?",category_id,map_id, tonumber(limit))
	end
	return content_column_mappings
end

return ContentColumnMappings