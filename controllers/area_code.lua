area_code = {}

local AreaCodes = require ("models.area_codes")
local cjson = require("cjson")
local response_body = require("utils.response_body")
local area_convert = require("dtos.area_convert")
area_code.successMess = "执行成功"
function area_code:getAreaByCode(code)
	local area = AreaCodes:getAreaByAreaCode(code)
	local areaDto = area_convert:convertAreaToAreaDto(area)
	return {json = response_body.build(200,area_code.successMess,{area =  areaDto})}
end

return area_code