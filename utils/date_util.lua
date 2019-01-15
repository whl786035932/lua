local date_util = {}

-- time (2017-12-26 20:23:56)
function date_util.getTimeLong(date)
	if date == nil then
		return 0
	else 
	   local t = date_util.getDateTimeLong(date) - date_util.getDateLong(date)
	    
	   return t
	end
end

-- date (2017-12-26 20:23:56)
function date_util.getDateLong(date)
	if date == nil then
		return 0
	else 
		local sp = split(date," ")
	    local dat = split(sp[1], "-")
	    local tim = split(sp[2], ":")

	    local t = os.time({year=dat[1],month=dat[2],day=dat[3], hour=0, min=0, sec=0}) * 1000
	    
	    return t
	end
end

-- date (2017-12-26 20:23:56)
function date_util.getDateTimeLong(date)
	if date == nil then
		return 0
	else 
		local sp = split(date," ")
	    local dat = split(sp[1], "-")
	    local tim = split(sp[2], ":")

	    local t = os.time({year=dat[1],month=dat[2],day=dat[3], hour=tim[1], min=tim[2], sec=tim[3]}) * 1000
	    
	    return t
	end
end

return date_util