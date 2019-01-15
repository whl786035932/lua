local Model =  require("lapis.db.model").Model
local Ads =  Model:extend("cimp_ad")

function Ads:getAdByPosition(position)
	
	local ad = Ads:select("where position=? and status =0  limit 1",position,{fields="id, name,url"})
	return ad[1]
end



return  Ads