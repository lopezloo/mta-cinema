addEventHandler("onClientPlayerSpawn", root,
	function()
		for k, v in pairs(getElementsByType("player")) do
			setElementCollidableWith(source, v, false)
		end

		if source == localPlayer then
			setElementFrozen(source, true)
			setTimer(setElementFrozen, 2000, 1, source, false)

			local room = getElementData(source, "colshape")
			if isElement(room) then
				triggerEvent("onClientElementColShapeHit", source, room, true)
			end
		end
	end
)

addEventHandler("onClientPlayerDamage", root, cancelEvent)
addEventHandler("onClientPlayerWasted", localPlayer, stopVideo)

-- rooms
addEventHandler("onClientElementColShapeHit", root,
	function(colshape, matchingDimensions)
		outputChatBox("onClientElementColShapeHit")

		if not matchingDimensions then return end
		if source == localPlayer then
			outputChatBox("Welcome in room " .. tostring(getElementData(colshape, "name")))

			local seconds = getElementData(colshape, "seconds")
			if seconds then
				playVideo(colshape, seconds)
			else
				playVideo(colshape)
			end
		elseif getElementType(source) == "player" then
			outputChatBox(getPlayerName(source) .. " entered to the room!")
		end
	end
)

addEventHandler("onClientElementColShapeLeave", root,
	function(colshape, matchingDimensions)
		outputChatBox("onClientElementColShapeLeave")

		if not matchingDimensions then return end

		if source == localPlayer then
			stopVideo(colshape)
			currentRoomQuery = {}
			guiSetVisible(request.window, false)
			guiGridListClear(request.gridlist)

			if getElementData(source, "votedToSkip") then
				triggerServerEvent("voteSkip", root, -1, colshape)
			end
		elseif getElementType(source) == "player" then
			outputChatBox(getPlayerName(source) .. " left from the room.")
		end
	end
)

addEventHandler("onClientElementDataChange", root,
	function(data, oldValue)
		if data == "currentMap" and getElementData(root, data) == nil then
			stopVideo()
		elseif data == "video" and getElementData(localPlayer, "colshape") == source then
			setElementData(localPlayer, "votedToSkip", false)
			playVideo(source) -- play new video if player is on this room

			outputChatBox(tostring(#currentRoomQuery))
			if #currentRoomQuery > 0 and getElementData(source, "video") == nil then
				outputChatBox("CLIENT: Deleting first query")
				table.remove(currentRoomQuery, 1)
				guiGridListRemoveRow(request.gridlist, 0)

				guiGridListSetItemColor(request.gridlist, 0, 1, 0, 255, 0)
				guiGridListSetItemColor(request.gridlist, 0, 2, 0, 255, 0)
				guiGridListSetItemColor(request.gridlist, 0, 3, 0, 255, 0)
			end
		end
	end
)

bindKey("h", "down",
	function()
		if getElementData(localPlayer, "anim") ~= false then
			exports["animsync"]:resetPedSyncedAnimation(localPlayer)
		else
			exports["animsync"]:setPedSyncedAnimation(localPlayer, "CAR", "Sit_relaxed")
		end
	end
)

bindKey("l", "down", 
	function()
		if getElementAlpha(localPlayer) == 255 then
			setElementAlpha(localPlayer, 0)
		else
			setElementAlpha(localPlayer, 255)
		end
	end
)

-- DEBUG
addEventHandler("onClientRender", root,
	function()
		for k, v in pairs(getElementsByType("colshape")) do
			--dxDrawText("col: " .. tostring(isElementWithinColShape(localPlayer, v)), 100, sY-25)
			break
		end
	end
)

addCommandHandler("pos", -- col pos grabber
	function()
		local x, y, z = getElementPosition(localPlayer)
		local int = getElementInterior(localPlayer)
		outputChatBox("POS: " .. x .. ", " .. y .. ", " .. z .. " int: " .. int)
		setClipboard(x .. ", " .. y .. ", " .. z .. " (int " .. int .. ")")
	end
)

setDevelopmentMode(true)