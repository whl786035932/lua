area = {}

local Areas = require ("models.areas")
local cjson = require("cjson")
local response_body = require("utils.response_body")
local area_convert = require("dtos.area_convert")

area.successMess="执行成功"
function area:getFirstAreas()

	local firstAreas = Areas:getFirstAreas()
	return {json = response_body.build(200,area.successMess,{areas =  firstAreas})}
end



function area:getChildAreas(area_id)
	local childAreas = Areas:getChildArea(area_id)
	return {json = response_body.build(200,area.successMess,{areas =  childAreas})}
end




return area