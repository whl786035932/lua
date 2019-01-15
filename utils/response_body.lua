local response_body = {}

function response_body.build(statusCode,message,data)
	response_body1 = {}
	response_body1["statusCode"] =  statusCode
	response_body1["message"] = message
	response_body1["data"] = data

	return response_body1
end

return response_body