userSub = {}
local UserSubs = require ("models.userSubs")
local response_body = require("utils.response_body")
 local cjson = require("cjson")
cjson.encode_empty_table_as_object(false)
userSub.successMess = "执行成功"
function userSub:addUserSub(userId,subword,matchword)
	UserSubs:addUserSub(userId,subword,matchword)

	return {json = response_body.build(200,userSub.successMess)}
end

function userSub:getUserMachword(userId)
	--local machword = UserSubs:getUserMatchWord(userId)
	--local subword = UserSubs:getUserSubs(userId) 
	--local data_result = {}
	--data_result["machword"] = machword
	--data_result["subword"] = subword


	local usersubs = UserSubs:getUserSubsAndMachWord(userId)



	local  response_body1 = {}
	response_body1["statusCode"] =  200
	response_body1["message"] = userSub.successMess
	local data = {}

	if usersubs ~=nil then
		data["machword"] = usersubs["machword"]
		data["userId"] = usersubs["userId"]
	else
		data["machword"] = ""
		data["userId"] = ""
	end
	response_body1["data"] = data

	--return {json = response_body.build(200,userSub.successMess,{words=usersubs})}
	return {json = response_body1}
end

return userSub