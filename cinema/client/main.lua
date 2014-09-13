-- PURPOSE: Main/misc stuff.

sX, sY = guiGetScreenSize()
--showCursor(true) -- there should be something like: if not allowedToViewSites then (while script was reset permissions was not resetting)
addEventHandler("onClientPlayerSpawn", root,
	function()
		if source == localPlayer then
			setElementFrozen(source, true)
			setTimer(setElementFrozen, 2000, 1, source, false)
			for k, v in pairs(getElementsByType("player")) do
				setElementCollidableWith(source, v, false)
			end			

			local room = getElementData(source, "colshape")
			if isElement(room) then
				triggerEvent("onClientElementColShapeHit", source, room, true)
			end
		else
			setElementCollidableWith(localPlayer, source, false)
		end
	end
)

addEventHandler("onClientPlayerDamage", root, cancelEvent)

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

bindKey("l", "down", 
	function()
		if getElementAlpha(localPlayer) == 255 then
			setElementAlpha(localPlayer, 0)
		else
			setElementAlpha(localPlayer, 255)
		end
	end
)

local requiredSites = { "vimeo.com", "twitch.tv", "www.twitch.tv", "redknife.tk",
"i.ytimg.com", "i1.ytimg.com", "yt3.ggpht.com", "csi.gstatic.com", "ssl.gstatic.com", "plus.googleapis.com", -- yt video images etc.
"gp1.googleusercontent.com", "gp2.googleusercontent.com", "gp3.googleusercontent.com", "gp4.googleusercontent.com", "gp5.googleusercontent.com", "gp6.googleusercontent.com", -- g+ avatars
"api.twitch.tv", "spade.twitch.tv", "static-cdn.jtvnw.net", "www-cdn.jtvnw.net", "s.jtvnw.net", "ttv-15.firebaseio.com" -- twitch stuff
}
requestBrowserPages(requiredSites)

addCommandHandler("permissions",
	function()
		requestBrowserPages(requiredSites)
	end
)