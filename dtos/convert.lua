local cjson = require("cjson")
local PrintTable = require "utils.print_table"
local convert = {}

function convert.getUrl(content)
	local videos = content["videos"]
    url = ""
	if videos ~= nil then
		local url_videos = cjson.decode(videos)
		local origin= url_videos["origin"]
		if origin ~= nil then
			url= origin["targetUrl"]
		end
	end
	return url
end

return convert