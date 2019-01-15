
local Model =  require("lapis.db.model").Model
local  Areas = require("models.areas")
local AreaCodes = Model:extend("area_code",{
	relations ={
		{"area",belongs_to = "Areas", key = "area_id"}
	}

})


--get area according area_code
function AreaCodes:getAreaByAreaCode(code)
	local area = nil

	local area_codes = AreaCodes:select("where code = ?  limit 1",code)
	if  #area_codes >0  then
		local area_code = area_codes[1]	
	    area = area_code:get_area()
	end
	return area
end


return AreaCodes