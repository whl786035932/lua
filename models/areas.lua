
local Model =  require("lapis.db.model").Model
local Areas =  Model:extend("area",{
	relations = {
		{"area_code", has_one ="AreaCodes",key="area_id"}
	}
})

function Areas:getFirstAreas()
	local areas =  Areas:select("where parent_id=  ? order by sequence asc",0 , {fields="id, name"})
	return areas
end

-- get area  区域
function Areas:getChildArea(area_id)
	local areas = Areas:select("where parent_id = ? order by sequence asc", area_id, {fields="id, name"})
	return areas
end


--get news limit by area
function Areas:getContentsByArea(area, map_id, limit)
	local contents = nil
	return contents
end
return  Areas