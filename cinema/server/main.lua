-- PURPOSE: Main/misc stuff.

local skins = getValidPedModels()

addEventHandler("onGamemodeMapStart", root,
	function(map)
		outputChatBox("Map " .. getResourceName(map) .. " started.")
		outputServerLog("Map " .. getResourceName(map) .. " started.")
		spawns = getElementsByType("spawnpoint")
		
		setTimer(
			function()
				for k, v in pairs(getElementsByType("player")) do
					spawn(v)
				end
			end, 5000, 1)

		setElementData(root, "currentMap", map)
	end
)

addEventHandler("onGamemodeMapStop", root,
	function(map)
		setElementData(root, "currentMap", nil)
		for k, v in pairs(getElementsByType("colshape")) do -- delete all the rooms
			destroyElement(v) -- onClientColShapeLeave & onClientElementColShapeLeave won't be trigged
		end
	end
)

addEventHandler("onPlayerJoin", root,
	function()
		outputChatBox("Hi. Please wait for spawn.", source)
		setTimer(spawn, 5000, 1, source)
		bindKey(source, "R", "down", "chatbox", "Room")
	end
)

addEventHandler("onPlayerWasted", root,
	function()
		setTimer(spawn, 5000, 1, source)
	end
)

addCommandHandler("Room",
	function(player, cmd, ...)
		local room = getElementData(player, "colshape")
		if isElement(room) then
			local msg = ""
			for k, v in pairs({ ... }) do
				msg = msg .. " " .. v
			end

			for k, v in pairs(getElementsWithinColShape(room, "player")) do
				outputChatBox("[ROOM] " .. getPlayerName(player) .. ":" .. msg)
			end
		end
	end
)

function spawn(player)
	if not player then return end
	if not spawns then
		outputChatBox("CRITICAL ERROR: No map loaded or map is broken", player)
		return
	end
	local spawnID = math.random(1, #spawns)

	local x = getElementData(spawns[spawnID], "posX")
	local y = getElementData(spawns[spawnID], "posY")
	local z = getElementData(spawns[spawnID], "posZ")
	local int =  getElementData(spawns[spawnID], "interior") or 0
	local rotZ = getElementData(spawns[spawnID], "rotZ") or 0

	outputChatBox(tostring(x) .. " " .. tostring(y) .. " " .. tostring(z) .. " " .. tostring(int) .. " " .. tostring(rotZ))

	spawnPlayer(player, x, y, z, rotZ, skins[math.random(1, #skins)], int, 0, nil)
	setCameraTarget(player, player)
	fadeCamera(player, true)
end

addCommandHandler("kill", function(player) if not isPedDead(player) then killPed(player) end end)
addCommandHandler("skin",
	function(player)
		if not isPedDead(player) then
			setElementModel(player, skins[math.random(1, #skins)])
			--[[local a = getElementData(player, "anim")
			if a ~= false then
				outputChatBox("dd")
				setTimer(setPedAnimation, 250, 1, player, a[1], a[2], 50, true, false, false, true)
			end]]--
		end
	end
)