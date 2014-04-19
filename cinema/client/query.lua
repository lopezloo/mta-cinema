currentRoomQuery = {}

local function secondsToTime(seconds)
	if type(seconds) == "number" then
		local minutes = math.floor(seconds/60)
		if minutes < 10 then
			minutes = "0" .. minutes
		end

		local scs = math.fmod(seconds, 60)
		if scs < 10 then
			scs = "0" .. scs
		end

		return minutes .. ":" .. scs
	else
		return seconds
	end
end

addEvent("updateQuery", true)
addEventHandler("updateQuery", root,
	function(vid, title, seconds)
		table.insert(currentRoomQuery, {vid, title, seconds})
		
		guiGridListAddRow(request.gridlist)
		local i = #currentRoomQuery - 1
		guiGridListSetItemText(request.gridlist, i, 1, title, false, false)
		guiGridListSetItemText(request.gridlist, i, 2, secondsToTime(seconds), false, false)
		guiGridListSetItemText(request.gridlist, i, 3, "0", false, false)

		guiGridListSetItemColor(request.gridlist, 0, 1, 0, 255, 0)
		guiGridListSetItemColor(request.gridlist, 0, 2, 0, 255, 0)
		guiGridListSetItemColor(request.gridlist, 0, 3, 0, 255, 0)
	end
)

addEvent("getFullQuery", true)
addEventHandler("getFullQuery", root,
	function(query)
		outputChatBox("getFullQuery")

		currentRoomQuery = query
		for k, v in pairs(query) do
			guiGridListAddRow(request.gridlist)
			guiGridListSetItemText(request.gridlist, k-1, 1, v[3], false, false)
			guiGridListSetItemText(request.gridlist, k-1, 2, secondsToTime(v[4]), false, false)
			guiGridListSetItemText(request.gridlist, k-1, 3, "0", false, false)

			guiGridListSetItemColor(request.gridlist, 0, 1, 0, 255, 0)
			guiGridListSetItemColor(request.gridlist, 0, 2, 0, 255, 0)
			guiGridListSetItemColor(request.gridlist, 0, 3, 0, 255, 0)
		end
	end
)