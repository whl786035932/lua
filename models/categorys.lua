
local Model =  require("lapis.db.model").Model
local Categorys =  Model:extend("cimp_column")





--get all categories
function   Categorys:getAll()
	
	local categories =  Categorys:select("where status =  ? order by sequence asc",0 , {fields="id, name, type, icon ,parent_id as parent , sequence, status, createtime as inserted_at ,updatetime as updated_at "})
	return categories 
    
   

end

--get first category
function Categorys:getFirstCategory()
		local firstCategories = Categorys:select("where status=? and parent_id  =  (select id from cimp_column where parent_id is NULL limit 1 )order by sequence asc ",0, {fields="id, name, type, icon ,parent_id as parent , sequence, status, createtime as inserted_at ,updatetime as updated_at"} )
		return firstCategories
end


--get child category

function Categorys:getChildCategory(category_id)
		local childCategories = Categorys:select("where status = ?  and parent_id = ? order  by sequence asc ", 0, category_id, {fields="id, name, type, icon ,parent_id as parent , sequence, status, createtime as inserted_at ,updatetime as updated_at"})
		return childCategories
end


function  Categorys:getChildCategoryBoothsByName(category_name)
	local childCategories = Categorys:select("where status = ?  and parent_id = (select id from cimp_column where name = ?) order  by sequence asc ", 0, category_name, {fields="id, name, type, icon ,parent_id as parent , sequence, status, createtime as inserted_at ,updatetime as updated_at"})
	return childCategories
end

--get category info
function Categorys:getCategoryInfo(category_id) 
		--local category  = Categorys:find(tonumber(category_id),{fields="id, name, type, icon ,parent_id as parent , sequence, status, createtime as inserted_at ,updatetime as updated_at"})
		local category = Categorys:select("where id=? and status = 0 limit 1",category_id,{fields="id, name, type, icon ,parent_id as parent , sequence, status, createtime as inserted_at ,updatetime as updated_at"})
		return category[1]

end





return Categorys