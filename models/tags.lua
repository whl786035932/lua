local Model =  require("lapis.db.model").Model
local Tags =  Model:extend("cimp_tag_tree")

function Tags:getTags(limit)
	-- 2代表2级节点
	local tags = Tags:select(" where type=2 and  enable=1  order by id asc limit "..limit, {fields="name"})
	return tags
end



return  Tags