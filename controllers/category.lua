category={}

local Categorys = require ("models.categorys")
local cjson = require("cjson")
local response_body = require("utils.response_body")
local category_convert = require("dtos.category_convert")

--get all categories

function  category:getAll()
		   
			local categories = Categorys:getAll()
			local categoryDtos = {}
			for k, v in ipairs(categories) do
				local categoryDto = category_convert:convertCategory(v)
				categoryDtos[k] = categoryDto
			end
			return {json = response_body.build(200,"执行成功",{categories =categoryDtos})}
			
end	

--get first category
function category:firstCategory()
	       
			local categories = Categorys:getFirstCategory()
			local categoryDtos = {}
			for k, v in ipairs(categories) do
				local categoryDto = category_convert:convertCategory(v)
				categoryDtos[k] = categoryDto
			end
			return {json = response_body.build(200,"执行成功",{categories =categoryDtos})}

end


--get child categories
function category:getChildCategory(category_id)
		   
			local categories = Categorys:getChildCategory(category_id)
			local categoryDtos = {}
			for k, v in ipairs(categories) do
				local categoryDto = category_convert:convertCategory(v)
				categoryDtos[k] = categoryDto
			end
			return {json = response_body.build(200,"执行成功",{categories =categoryDtos})}
end

--get category info
function category:getCategoryInfo(category_id)
			
			local category = Categorys:getCategoryInfo(category_id)
			local categoryDto = category_convert:convertCategory(category)
			if categoryDto == nil  then
				return {json = response_body.build(404,"栏目不存在",{category =categoryDto})}
			else 

				return {json = response_body.build(200,"执行成功",{category =categoryDto})}
			end
			
end


--build fullt tree
-- function category:buildFullTree() 
-- 	local categories = Categorys:getAll()
-- 	-- print("1111111111111111111111111111111111111111111111111111111111111111")
-- 	local categoryDtos = {}
-- 	for k, v in ipairs(categories) do
-- 		-- print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~parent=="..v["parent"])
-- 		local categoryDto = category_convert:convertCategoryWithChildren(v)
-- 		categoryDtos[k] = categoryDto
-- 	end
-- 	-- print("22222222222222222222222222222222222222222222222categoryDtos="..#categoryDtos)

-- 	if categoryDtos ~=nil and #categoryDtos >1  then
-- 		-- print("3333333333333333333333333333333333333333333333")
-- 		local size = #categoryDtos
-- 		-- print("---------------------------size="..size)
-- 		for i=2 , size  do
			
-- 			for j=i-1, 1,-1 do
-- 				local val_j= categoryDtos[j]
-- 				local val_j_size = #val_j["children"]
-- 				local parentId= val_j.parent
				
-- 				local val_i = categoryDtos[i]
-- 				local id = val_i.id
-- 				if parentId ==  id  then
-- 					print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")	
-- 					table.insert(val_j["children"], val_i)
-- 				end


-- 			end
-- 		end
-- 	end

-- 	local categoryDtoList = {}
-- 	for k,v in ipairs(categoryDtos) do
-- 		local categoryDto  = v
-- 		local parentId = v["parent"]
-- 		if parentId ~=-1 then
-- 			table.insert(categoryDtoList,categoryDto)
-- 		end
-- 	end

-- 	print("ssssssssssssssssss="..#categoryDtoList)
-- 	return {json = response_body.build(200,"执行成功",{categories =categoryDtoList})}
-- end

--------------------------------build full tree new
function category:buildFullTree() 
	local categories = Categorys:getFirstCategory()
	
	local categoryDtos = {}
	for k, v in ipairs(categories) do
		local categoryDto = category_convert:convertCategoryWithChildren(v)	
		local child_categories = Categorys:getChildCategory(v["id"])
		for kchild, vchild in ipairs(child_categories) do
			local child_categoryDto = category_convert:convertCategoryWithChildren(vchild)
			-- table.insert(categoryDto["children"], child_categoryDto)
			local thirdLevel_child_categories = Categorys:getChildCategory(vchild["id"])
			for kchild_third, vchild_third in ipairs(thirdLevel_child_categories) do
				print("----------------------------------------------lllllllllllllllllllllllllllllllllll------------------------------------------------------------------------")
				local third_child_categoryDto = category_convert:convertCategoryWithChildren(vchild_third)
				table.insert(child_categoryDto["children"], third_child_categoryDto)
				print("-----------------------------------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@----"..#child_categoryDto["children"]..third_child_categoryDto["name"])
			end
			table.insert(categoryDto["children"], child_categoryDto)

		end
		-- for kThirdLevel, vThirdLevle in ipairs()

		categoryDtos[k] = categoryDto
	end

	return {json = response_body.build(100000,"执行成功",{classifications =categoryDtos})}
end

--获取子栏目---根据栏目id

function category:getChildCategoryBooths(category_id)
	   
		local categories =  Categorys:getChildCategory(category_id)
		local categoryDtos = {}
		for k, v in ipairs(categories) do
			local categoryDto = category_convert:convertCategoryWithChildren(v)
			categoryDtos[k] = categoryDto
		end
		return {json = response_body.build(100000,"执行成功",{classifications =categoryDtos})}
end
--获取子栏目---根据栏目名称

function category:getChildCategoryBoothsByName(category_name)
	   
		local categories =  Categorys:getChildCategoryBoothsByName(category_name)
		local categoryDtos = {}
		for k, v in ipairs(categories) do
			local categoryDto = category_convert:convertCategoryWithChildren(v)
			local child_categories = Categorys:getChildCategory(v["id"])
			for kchild, vchild in ipairs(child_categories) do
				local child_categoryDto = category_convert:convertCategoryWithChildren(vchild)
				table.insert(categoryDto["children"], child_categoryDto)
			end

			categoryDtos[k] = categoryDto
		end
		return {json = response_body.build(100000,"执行成功",{classifications =categoryDtos})}
end


return category