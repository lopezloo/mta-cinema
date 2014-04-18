function addVideoToQuery(room, theType, vid)
	if theType == "yt" then
		fetchRemote("http://gdata.youtube.com/feeds/api/videos/" .. vid .. "?v=1", onVideoDataReturned, "", false, theType, room, vid) -- ?v=2
	elseif theType == "twitch" then
		fetchRemote("http://api.justin.tv/api/stream/list.json?channel=" .. vid, onVideoDataReturned, "", false, theType, room, vid)
	end
end

function onVideoDataReturned(data, errno, theType, room, vid)
	if errno == 0 then
		local title, seconds
		if theType == "yt" then
			local a = string.find(data, "<title type='text'>") + string.len("<title type='text'>")
			title = string.sub(data, a, string.find(data, "</title>", a) - 1)
			outputServerLog("YT-Title: " .. title)

			local a = string.find(data, "<yt:duration seconds='") + string.len("<yt:duration seconds='")
			seconds = string.sub(data, a, string.find(data, "'/>", a) - 1)
			outputServerLog("YT-Seconds: " .. seconds)

			seconds = seconds+5 -- 5 extra seconds (loading in clients can took some time)
		else
			if data == "[]" then
				return -- channel offline
			end

			local a = string.find(data, '"title":"') + string.len('"title":"')
			title = string.sub(data, a, string.find(data, '","', a) - 1)
			seconds = "-"
			outputServerLog("Twitch title: " .. tostring(title))
		end

		if #roomQuery[room] == 0 then
			outputChatBox("requestVideo list is currently empty")

			roomCurrentVideo[room] = {theType, vid, title, tonumber(seconds)}
			setElementData(room, "video", {theType, vid}) -- trigger to clients
			setElementData(room, "seconds", 0)
			if type(seconds) == "number" and seconds > 0 then
				roomUpdateTimer[room] = setTimer(updateRoomTime, 1000, tonumber(seconds), room)
			end
		end

		table.insert(roomQuery[room], {theType, vid, title, seconds})
		for k, v in pairs(getElementsWithinColShape(room, "player")) do
			triggerClientEvent("updateQuery", v, vid, title, seconds)
		end	
	else
		outputServerLog("ERROR: I can't retrieve data about video from server.")
	end
end