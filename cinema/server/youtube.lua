-- PURPOSE: Contacting with video services API and getting info about videos.

function addVideoToQuery(room, theType, vid)
	if theType == "yt" then
		fetchRemote("http://gdata.youtube.com/feeds/api/videos/" .. vid .. "?v=1", onVideoDataReturned, "", false, theType, room, vid) -- ?v=2
	elseif theType == "vimeo" then
		fetchRemote("http://vimeo.com/api/v2/video/" .. vid .. ".xml", onVideoDataReturned, "", false, theType, room, vid)	
	elseif theType == "dailymotion" then
		fetchRemote("https://api.dailymotion.com/video/" .. vid .. "?fields=title,duration", onVideoDataReturned, "", false, theType, room, vid)
		-- Dailymotion api works only with https
	elseif theType == "twitch" then
		fetchRemote("https://api.twitch.tv/kraken/streams/" .. vid, onVideoDataReturned, "", false, theType, room, vid)
		-- Twitch is broken because now it's require SSL too. Pokerface.
		-- Old api link: http://api.justin.tv/api/stream/list.json?channel=
	end
end

function onVideoDataReturned(data, errno, theType, room, vid)
	if errno == 0 then
		local title, seconds
		if theType == "yt" then
			local a = string.find(data, "<title type='text'>") + string.len("<title type='text'>")
			title = string.sub(data, a, string.find(data, "</title>", a) - 1)
			outputServerLog("YT-Title: " .. title)

			a = string.find(data, "<yt:duration seconds='") + string.len("<yt:duration seconds='")
			seconds = tonumber(string.sub(data, a, string.find(data, "'/>", a) - 1))
			outputServerLog("YT-Seconds: " .. seconds)

			seconds = seconds+5 -- 5 extra seconds (loading in clients can took some time)
		elseif theType == "vimeo" then
			local a = string.find(data, "<title>") + string.len("<title>")
			title = string.sub(data, a, string.find(data, "</title>", a) - 1)

			a = string.find(data, "<duration>") + string.len("<duration>")
			seconds = tonumber(string.sub(data, a, string.find(data, "</duration>") - 1))
			outputServerLog("Vimeo-Title: " .. title)
			outputServerLog("Vimeo-Seconds: " .. seconds)
		elseif theType == "dailymotion" then
			local a = string.find(data, '"title":"') + string.len('"title":"')
			title = string.sub(data, a, string.find(data, ',"', a) - 1)

			a = string.find(data, a, string.find(data, '"duration":') - 1)
			seconds = tonumber(string.sub(data, a, string.find(data, ',"')))
			outputServerLog("Dailymotion-Title: " .. title)
			outputServerLog("Dailymotion-Seconds: " .. seconds)
		elseif theType == "twitch" then
			if not string.find(data, '"game"') then
				return -- channel offline
			end

			local a = string.find(data, '"status":"') + string.len('"status":"')
			title = string.sub(data, a, string.find(data, '","', a) - 1)
			seconds = "-"
			outputServerLog("Twitch title: " .. tostring(title))
		end

		if #roomQuery[room] == 0 then
			outputChatBox("requestVideo list is currently empty")

			roomCurrentVideo[room] = {theType, vid, title, seconds}
			setElementData(room, "video", {theType, vid}) -- data which store only current video data
			setElementData(room, "seconds", 0) -- too
			if type(seconds) == "number" and seconds > 0 then
				roomUpdateTimer[room] = setTimer(updateRoomTime, 1000, seconds, room)
			end
		end

		table.insert(roomQuery[room], {theType, vid, title, seconds})
		for k, v in pairs(getElementsWithinColShape(room, "player")) do
			triggerClientEvent("updateQuery", v, vid, title, seconds)
		end	
	else
		outputServerLog("ERROR: I can't retrieve data about video from " .. theType .. " API (error " .. errno .. ")")
	end
end