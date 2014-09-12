-- PURPOSE: Managing rooms and requesting videos.

roomQuery = {}
roomCurrentVideo = {}
roomUpdateTimer = {}
roomVoteSkip = {}

function createRoom(name, screens, x, y, z, width, depth, height)
	local col = createColCuboid(x, y, z, width, depth, height)
	if not screens or not col then
		outputServerLog("Can't create specified room.")
		return
	end

	outputServerLog("Room " .. #getElementsByType("colshape") .. " created")

	setElementData(col, "name", name or "Unnamed")
	setElementData(col, "screens", screens)

	roomQuery[col] = {}
	roomCurrentVideo[col] = {}
	roomVoteSkip[col] = 0
end

addEventHandler("onElementColShapeHit", root,
	function(colshape, matchingDimensions)
		if getElementType(source) == "player" and matchingDimensions then
			setElementData(source, "colshape", colshape)

			if not roomCurrentVideo[colshape] and #roomQuery[colshape] > 0 then
				outputServerLog("Trying to unpausing/unfreezing room " .. tostring(colshape))
				nextVideo(colshape) -- 'unfreeze' room
			end

			if #roomQuery[colshape] > 0 then
				triggerClientEvent("getFullQuery", source, roomQuery[colshape])
			end
		end
	end
)

addEventHandler("onElementColShapeLeave", root,
	function(colshape, matchingDimensions)
		if getElementType(source) == "player" and matchingDimensions then
			setElementData(source, "colshape", false)
		end
	end
)

addEvent("requestVideo", true)
addEventHandler("requestVideo", root,
	function(theType, id)
		local colshape = getElementData(client, "colshape")
		outputChatBox("requestVideo for room " .. tostring(colshape) .. " (video " .. tostring(id) .. ")")
		if isElement(colshape) then
			addVideoToQuery(colshape, theType, id)
		end
	end
)

addEvent("voteSkip", true) -- TODO
addEventHandler("voteSkip", root,
	function(count, room)
		if not room then room = getElementData(client, "colshape") end
		if room then
			local players = getElementsWithinColShape(room, "player")
			roomVoteSkip[room] = roomVoteSkip[room] + count

			if count > 0 then
				setElementData(client, "votedToSkip", true)
			else
				setElementData(client, "votedToSkip", false)
			end

			if roomVoteSkip[room] > #players/4 then
				outputChatBox("Skipping current video", room)
				nextVideo(room)
			end
		end
	end
)

function nextVideo(room) -- (shape)
	setElementData(room, "video", nil)
	if roomCurrentVideo[room] ~= 0 then
		outputChatBox("Current video: " .. tostring(roomCurrentVideo[room][1]) .. " " .. tostring(roomCurrentVideo[room][2]) .. " " .. tostring(roomCurrentVideo[room][3]))
		--table.remove(roomQuery[room], table.find(roomQuery[room], roomCurrentVideo[room]))
		table.remove(roomQuery[room], 1) -- deleting first query
	end

	if isTimer(roomUpdateTimer[room]) then
		killTimer(roomUpdateTimer[room])
	end

	if #roomQuery[room] == 0 then
		outputServerLog("No next video for room " .. tostring(room))
		roomCurrentVideo[room] = {}
		return
	end

	local players = getElementsWithinColShape(room, "player")
	if #players > 0 then
		roomCurrentVideo[room] = roomQuery[room][1]

		outputChatBox("Next video: " .. tostring(roomQuery[room][1][1]) .. " " .. tostring(roomQuery[room][1][2]) .. " " .. tostring(roomQuery[room][1][3]) .. " " .. tostring(roomQuery[room][1][4]))

		setElementData(room, "video", { roomQuery[room][1][1], roomQuery[room][1][2] }) -- vidType, vid
		setElementData(room, "seconds", 0)
		if type(roomQuery[room][1][4]) == "number" and roomQuery[room][1][4] > 0 then
			roomUpdateTimer[room] = setTimer(updateRoomTime, 1000, roomQuery[room][1][4], room)
		end

		--for k, v in pairs(players) do setElementData(v, "votedToSkip", false) end
	else
		roomCurrentVideo[room] = {}
		setElementData(room, "video", nil)
		setElementData(room, "seconds", 0)
		outputServerLog("Room " .. tostring(room) .. " stopped  - no players")
		-- maybe clearing query when no players ?
	end
end

function updateRoomTime(room)
	local seconds = getElementData(room, "seconds") + 1
	setElementData(room, "seconds", seconds)
	if seconds == roomCurrentVideo[room][4] then
		nextVideo(room)
	end
end

-- debug
--[[addCommandHandler("querylist", 
	function(player)
		local col = getElementData(player, "colshape")
		if isElement(col) then
			if #roomCurrentVideo[col] ~= 0 then
				outputChatBox("Current video: " .. tostring(roomCurrentVideo[col][1]) .. " " .. tostring(roomCurrentVideo[col][2]) .. " " .. tostring(roomCurrentVideo[col][3]))
			else
				outputChatBox("Current video: none")
			end

			if roomQuery[col] ~= 0 then
				for k, v in pairs(roomQuery[col]) do
					outputChatBox(k .. ". " .. tostring(v[1]) .. " " .. tostring(v[2]) .. " " .. tostring(v[3]))
				end
			else
				outputChatBox("Query: empty")
			end
		end
	end
)]]--