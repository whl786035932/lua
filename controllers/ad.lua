ad = {}

local Ads = require ("models.ads")
local cjson = require("cjson")
local response_body = require("utils.response_body")


area.successMess="执行成功"
function ad:getAdByPosition(position)

	local ads = Ads:getAdByPosition(position)
	return {json = response_body.build(200,area.successMess,{ad =  ads})}
end
return ad