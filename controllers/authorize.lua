--盒子的换串controller

authorize =  {}
authorize.egp_gan= "defaultHD/en/goAuthorization2jx.jsp"
authorize.localUrl = "http://10.2.17.132/mnt/mam/rtphint.mp4"
local http = require "resty.http" 
local httpc = http:new()
local printtable = require "utils.print_table"
local Contents   = require "models.contents"
local cjson = require("cjson")
cjson.encode_empty_table_as_object(false)
-------------------------------------------------------------------------------------------贵州
--贵州的换串接口，先获取视频的真实id, 根据视频的真实id, 获取视频的播放地址
function authorize:authorize_qian(nns_ids,nns_type, nns_video_type, nns_id_func, nns_url_func, nns_mac, nns_mac_id,  nns_version,  nns_user_id,  nns_webtoken, nns_output_type)

	--获取视频的真实id
	local video_id = authorize:authorize_qian_getId(nns_ids,nns_type, nns_video_type, nns_id_func, nns_mac, nns_mac_id,  nns_version,  nns_user_id,  nns_webtoken, nns_output_type)

	--根据视频真实的id,获取视频的播放地址

	response_state , url = authorize_qian_getUrl(video_id, nns_video_type, nns_url_func, nns_version, nns_user_id, nns_webtoken, nns_output_type )


	return {json = authorize:build_response_qian(response_state, url) }


end


--获取视频的真实id
function authorize:authorize_qian_getId(nns_ids,nns_type, nns_video_type, nns_func, nns_mac, nns_mac_id,  nns_version,  nns_user_id,  nns_webtoken, nns_output_type)
	
	local  id_url  = "http://10.21.4.234/gzgd/EPGV2?nns_ids="..nns_ids .."&nns_type="..nns_type.."&nns_video_type="..nns_video_type.."&nns_func="..nns_func.."&nns_mac="..nns_mac.."&nns_mac_id="..nns_mac_id.."&nns_version="..nns_version.."&nns_user_id="..nns_user_id.."&nns_webtoken="..nns_webtoken.."&nns_output_type="..nns_output_type

	print("get the real id  request_url==================================================================================="..id_url)
	local res, err = httpc:request_uri(id_url, {
	 method = "GET",
	 headers = {
		 ["Content-Type"] = "application/json"
	 }
	 })
	
	if res ~= nil then
		print("get the real id**************************************************************************************")
		printtable:print_r(res)
	end


	
	--print("调取贵州的获取视频的真实id的返回结果error===="..printtable:print_r(err))
	--根据返回的结果，取到response_state状态码和video_id 
	--local  response_state = res["state"]
	local  video_id = ""
	local  body =  cjson.decode(res.body)
	local il_list = body.l.il
	print("il_list----------------------------------------is null  or  not-----------------------------------------------------")
	if il_list~=nil  and #il_list>0 then
		print("il_list  is   not  null   and  length>0(((((((((((((((((((((((((((((((((((((((((((((((((((((")
		local arg_list = il_list[1]
		if arg_list~=nil then
			 video_id = il_list[1].arg_list.video_id
		end
		
	end

	print("get  the video  id @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@="..video_id)
	return video_id
end


--获取贵州视频的播放地址

function authorize_qian_getUrl(nns_video_id, nns_video_type, nns_func,  nns_version,  nns_user_id,  nns_webtoken, nns_output_type)
	print("to   according to id to get play url %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%=")
	--local  video_url  = "http://10.21.4.236/gzgd/AuthIndexStandard?nns_video_id="..nns_video_id.."&nns_video_type="..nns_video_type.."&nns_func="..nns_func.."&nns_version="..nns_version.."&nns_user_id="..nns_user_id.."&nns_webtoken="..nns_webtoken.."&nns_output_type="..nns_output_type
	--local  video_url  = "http://10.21.4.236/gzgd/AuthIndexStandard?nns_video_id=".."5a7b2e946ca7c6bc00ea5e75f72255f3".."&nns_video_type="..nns_video_type.."&nns_func="..nns_func.."&nns_version="..nns_version.."&nns_user_id="..nns_user_id.."&nns_webtoken="..nns_webtoken.."&nns_output_type="..nns_output_type
	local  video_url  = "http://10.21.4.236/gzgd/AuthIndexStandard?nns_video_id="..nns_video_id.."&nns_video_type="..nns_video_type.."&nns_func="..nns_func.."&nns_version="..nns_version.."&nns_user_id="..nns_user_id.."&nns_webtoken="..nns_webtoken.."&nns_output_type="..nns_output_type
	print("get the real play url =url+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"..video_url)
	local res, err = httpc:request_uri(video_url, {
	 method = "GET",
	 headers = {
		 ["Content-Type"] = "application/json"
	 }
	 })

	
	print("get the realed result&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
	printtable:print_r(res)
	local body = cjson.decode(res.body)
	local response_state = body.result.state
	local url = ""
	local local_video = body.video
	if  local_video ~=nil then
		local local_index  = local_video.index
		if local_index ~=nil then
			local local_media = local_index.media
			if local_media ~=nil then
				url = local_media.url
			end
		end
	end
	-- url =body.video.index.media.url

	return response_state, url
end

--组建贵州的获取地址的返回结构
function authorize:build_response_qian(state, url)
	response_qian =  {}
	response_qian["state"] =  state
	response_qian["url"] =  url
	return response_qian
end


---------------------------------------------------------------------------------------------------本地
--获取本地的视频的url,本地的视频播放地址不转换，盒子传进来是什么，返回去就是什么
function   authorize:authorize_wangbo_qian(nns_ids)
	--根据本地的新闻的id去换取url
	local url = ""
	local videoUrls = Contents:getUrlAccordingToId(nns_ids)

	if videoUrls~=nil and videoUrls["videos"] ~=nil then
		--begin
		local url_videos = cjson.decode(videoUrls["videos"])
			local origin= url_videos["origin"]
			
			if origin==nil then

			else
				url= origin["targetUrl"]
				
			end

		--end
	end
	realUrl = string.gsub(url, "\\", "");
	print("replaced url=========================="..realUrl)
	return {json = authorize:build_response_qian(0, realUrl)}
end

function  authorize:authorize_wangbo_gan(transferIp,progId)
	local url = ""
	local videoUrls = Contents:getUrlAccordingToId(nns_ids)

	if videoUrls~=nil and videoUrls["videos"] ~=nil then
		--begin
		local url_videos = cjson.decode(videoUrls["videos"])
			local origin= url_videos["origin"]
			
			if origin==nil then

			else
				url= origin["targetUrl"]
				
			end

		--end
	end
	 return {json = authorize:build_response_gan(200, "1", url, url, "本地换串成功") }
end

----------------------------------------------------------------------------------------------------江西

 
--获取江西的视频的播放串
function  authorize:authorize_gan(transferIp,typeId, playType, progId, contentType, business, baseFlag,cookie )
	print("get the  gan  url  =========================")

	--先根据盒子传过来的请求地址去请求播放地址
	if transferIp=="" or transferIp==nil or  cookie =="" or cookie==nil  then
		return {json = authorize:build_response_gan(403, "0", "", "", "鉴权失败") }
	end
	--transferIp = string.sub(transferIp,0,string.find(transferIp,"/",-1,-2))
	transferIp = authorize:subString(transferIp,"/")
	print("gan layUrl=============================================="..transferIp)
	local  play_url  = transferIp..egp_gan.."?progId="..progId.."&typeId="..typeId.."&contentType="..contentType.."&business="..business.."&baseFlag="..baseFlag.."&playType="..playType.."&cookie="..cookie

	local res, err = httpc:request_uri(play_url, {
	 method = "GET",
	 headers = {
		 ["Content-Type"] = "application/x-www-form-urlencoded",
	 }
	 })

	--print("调用江西获取视频的播放地址获取的结果="..
	printtable:print_r(res)
	local response_code = res["code"]
	local playFlag = res["playFlag"]
	local playUrl = res["playUrl"]
	local reportUrl = res["reportUrl"]
	local message = res["message"]

	--根据获取的播放地址，去替换rtsp等
	local uriSub = ""
	if playUrl~=nil then
		local rtspIndex = string.find(playUrl,"rtsp")
		local httpIndex = string.find(playUrl,"http")
		if rtspIndex > 0  then
		    uriSub = string.sub(playUrl, rtspIndex+4,playUrl.find("H.264")+5)
			uriSub = "http"..uriSub
		elseif httpIndex > 0  then
			uriSub = playUrl
		end
	end

	--组装江西的返回结果
	return {json = authorize:build_response_gan(response_code, playFlag, uriSub, reportUrl, message) }


end

--组装江西的返回结构
function  authorize:build_response_gan(response_code, playFlag, playUrl, reportUrl, message)
	response_gan = {}
	response_gan["code"] = response_code
	response_gan["playFlag"] =  playFlag
	response_gan["playUrl"]  = playUrl
	response_gan["reportUrl"] = reportUrl
	response_gan["message"] = message
	return response_gan

end
--截取到最后一个字符出现的位置
function authorize:subString(str,k) 
	ts = string.reverse(str)
	_,i= string.find(ts,k)
	m = string.len(ts) - i +1
	return string.sub(str,1,m)
end


return authorize