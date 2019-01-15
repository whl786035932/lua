category_convert = {}

local cjson = require("cjson")
local date_util = require("utils.date_util")
function category_convert:convertCategory(category)
	local categoryDto = {}
	local category_ori=category
	if category_ori == nil then
	else
		
		categoryDto["id"] =  category_ori["id"]
		categoryDto["name"] = category_ori["name"]
		print ("获取的栏目名称="..category_ori["name"])
		local parent=category_ori["parent"]
		categoryDto["parent"] = 0
		if  not  parent  then
			
			categoryDto["parent"] = parent
		else
			
		end

		categoryDto["status"]  = category_ori["status"]
		categoryDto["inserted_at"] = date_util.getDateLong(category_ori["inserted_at"])
		categoryDto["updated_at"] = date_util.getDateLong(category_ori["updated_at"])
		local icon = category_ori["icon"]
		--print ("图标"..icon)
		if icon ~= nil then
			
			local icon_ori = cjson.decode(category_ori["icon"])
			if icon_ori~=nil  then
				local targetIcon = icon_ori["targetUrl"] 
				if targetIcon ~= nil then
				 	categoryDto["icon"]  =  targetIcon
				 else 
				 	categoryDto["icon"] = ""
				 end
			end

		end

		categoryDto["path"] = ""
		categoryDto["description"] = ""
		return categoryDto
    end 
end

function category_convert:convertCategoryWithChildren(category)
	local categoryDto = {}
	local category_ori=category
	if category_ori == nil then
	else
		
		categoryDto["id"] =  category_ori["id"]
		categoryDto["name"] = category_ori["name"]
		-- print ("获取的栏目名称="..category_ori["name"])
		local parent=category_ori["parent"]
		if parent==nil then
			parent = -1
		end

		categoryDto["pId"] = parent
		
		categoryDto["type"]= category_ori["type"]
		categoryDto["status"]  = category_ori["status"]
		-- categoryDto["inserted_at"] = date_util.getDateLong(category_ori["inserted_at"])
		-- categoryDto["updated_at"] = date_util.getDateLong(category_ori["updated_at"])
		local icon = category_ori["icon"]
		--print ("图标"..icon)
		if icon ~= nil then
			
			local icon_ori = cjson.decode(category_ori["icon"])
			if icon_ori~=nil  then
				local targetIcon = icon_ori["targetUrl"] 
				if targetIcon ~= nil then
				 	categoryDto["icon"]  =  targetIcon
				 else 
				 	categoryDto["icon"] = ""
				 end
			end

		end

		-- categoryDto["path"] = ""
		-- categoryDto["description"] = ""
		categoryDto["children"] = {}
		return categoryDto
    end 

end



return category_convert