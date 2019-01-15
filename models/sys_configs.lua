local Model =  require("lapis.db.model").Model
local Sysconfigs =  Model:extend("sys_config")
local PrintTable = require "utils.print_table"
function Sysconfigs:elSearchUrl()
	
	local url = Sysconfigs:select("where cimp_key='elSearchUrl' ",{fields="json"} )
	--print("少时诵诗书所所所所所所所所所所所所所所所所所所所所所====="..url[1].json)
	return url[1].json
end



return  Sysconfigs