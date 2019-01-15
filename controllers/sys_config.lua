sys_config = {}

local SysConfigs = require ("models.sys_configs")
--返回系统配置的elasticsearch地址
local PrintTable = require "utils.print_table"
function sys_config:elSearchUrl()
	local esUrlTab =  SysConfigs:elSearchUrl()
	
	
	return esUrlTab
	
end
return sys_config