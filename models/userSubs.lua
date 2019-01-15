local Model =  require("lapis.db.model").Model
local UserSubs =  Model:extend("user_sub")
local printTable = require "utils.print_table"
--添加/修改用户的订阅号
function UserSubs:addUserSub(userId,subword, machword)
	
	local userSubs = UserSubs:select("where userId=?  limit 1",userId)
	if  #userSubs==0 then
		print("插入一条新的记录=================")
		--插入一条新的记录
		local userSubInsert =  UserSubs:create({userid = userId, subword = subword,machword = machword})

	else
		--修改用户的订阅记录
		print("修改用户的订阅记录=================")
		local usersub = userSubs[1]

		if subword~=nil then
			usersub.subword = subword
			usersub:update("subword")
		end
		
		if machword~=nil then
			usersub.machword = machword
			usersub:update("machword")
		end
		
		

	end
end

--根据用户的id获取用户的订阅号
function  UserSubs:getUserSubs(userId) 
	local usersubs = UserSubs:select("where userId=? limit 1",userId,{fields="subword"})
	if #usersubs>0 then
		return usersubs[1]

	end
	
	return usersubs
	
end


function  UserSubs:getUserMatchWord(userId)
	local usersubs = UserSubs:select("where userId=? limit 1",userId,{fields="machword"})
	if #usersubs>0 then
		return usersubs[1]

	end
	
	return usersubs
end




function UserSubs:getUserSubsAndMachWord(userId)
	
	local userSubs = UserSubs:select("where userId=?  limit 1",userId,{fields="userId,subword,machword"})
	return userSubs[1]
end

return  UserSubs