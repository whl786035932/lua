tag = {}
local Tags = require ("models.tags")
local UserSubs = require ("models.userSubs")
local cjson = require("cjson")
local response_body = require("utils.response_body")
local string_util = require("utils.string_util")
local printTable = require "utils.print_table"

tag.successMess="执行成功"
function tag:getUserTags(userId,limit)
	local usersubsArr = {}
	local tags = Tags:getTags(limit)
	local usersubstr = UserSubs:getUserSubs(userId)  --值为：订阅号1， 订阅号2
	if usersubstr~=nil and usersubstr["subword"] ~=nil then

		usersubsArr= string_util:split(usersubstr["subword"],",")
	end
 
	local tagDtos = {}
	
	

	for k, v in ipairs(tags) do
		local tagDto = {}
		tagDto["name"] = v["name"]
		tagDto["subed"] = 0

		local hassub = string_util:in_array(usersubsArr,v["name"])

		if hassub == true then		
			tagDto["subed"] =1 
		end
		tagDtos[k] = tagDto	
	end

	return {json = response_body.build(200,tag.successMess,{tags =  tagDtos})}
end







return tag
