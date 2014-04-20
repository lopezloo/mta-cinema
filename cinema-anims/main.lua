local startPos
positioning = false

bindKey("h", "down",
	function()
		if getElementData(localPlayer, "anim") ~= false then
			if startPos ~= nil then
				toggleAllControls(true, true, false)
				removeEventHandler("onClientPreRender", root, updatePosition)
				startPos = nil
			end
			setElementData(localPlayer, "anim", false)
		else
			startPos = {}
			startPos[1], startPos[2], startPos[3] = getElementPosition(localPlayer)			
			setElementData(localPlayer, "anim", anims[currentAnim])
		end
	end
)

bindKey("j", "down",
	function()
		if not positioning then
			if getElementData(localPlayer, "anim") ~= false then
				toggleAllControls(false, true, false)
				addEventHandler("onClientPreRender", root, updatePosition)
			else
				return
			end
		else
			toggleAllControls(true, true, false)
			removeEventHandler("onClientPreRender", root, updatePosition)
		end
		positioning = not positioning
	end
)

function updatePosition()
	local x, y, z = 0, 0, 0
	if getKeyState("w") then
		y = y + 0.05
	end

	if getKeyState("s") then
		y = y - 0.05
	end

	for k, v in pairs(getBoundKeys("left")) do
		if getKeyState(k) then
			x = x - 0.05
		end
	end

	for k, v in pairs(getBoundKeys("right")) do
		if getKeyState(k) then
			x = x + 0.05
		end
	end

	--[[if getKeyState("mouse_wheel_up") then -- doesn't work omg
		z = z + 0.1
	end
	if getKeyState("mouse_wheel_down") then
		z = z - 0.1
	end]]--

	if getKeyState("arrow_u") then
		z = z + 0.05
	end
	if getKeyState("arrow_d") then
		z = z - 0.05
	end	

	dxDrawLine3D(startPos[1], startPos[2], startPos[3], startPos[1] + 0.05, startPos[2] + 0.05, startPos[3] + 0.05, tocolor(255, 0, 0, 200), 10)
	x, y, z = getPositionFromElementOffset(localPlayer, x, y, z)
	if math.abs(startPos[1] - x) > 4 or math.abs(startPos[2] - y) > 4 or math.abs(startPos[3] - z) > 2 then
		x, y, z = getElementPosition(localPlayer)
	else
		setElementPosition(localPlayer, x, y, z)
	end
	
	dxDrawLine3D(x, y + 0.5, z, x, y + 2, z, tocolor(0, 255, 0, 200))
	dxDrawLine3D(x, y - 0.5, z, x, y - 2, z, tocolor(0, 255, 0, 200))

	dxDrawLine3D(x + 0.5, y, z, x + 2, y, z, tocolor(0, 255, 0, 200))
	dxDrawLine3D(x - 0.5, y, z, x - 2, y, z, tocolor(0, 255, 0, 200))

	dxDrawLine3D(x, y, z + 0.5, x, y, z + 1, tocolor(0, 255, 0, 50))
	dxDrawLine3D(x, y, z - 0.5, x, y, z - 1, tocolor(0, 255, 0, 50))	
end

addEventHandler("onClientElementDataChange", root,
	function(data, oldValue)
		if data == "anim" and (getElementType(source) == "ped" or getElementType(source) == "player") then
			local anim = getElementData(source, "anim")
			if oldValue ~= false and anim == false then
				setPedAnimation(source, "ped", "facanger", 50, true, true, true, true)
				setElementCollisionsEnabled(source, true)
				setElementFrozen(source, false)
			elseif anim ~= false then
				setElementFrozen(source, true)
				setElementCollisionsEnabled(source, false)
				setPedAnimation(source, anim[1], anim[2], 50, true, false, false, true)
			end
		end
	end
)

addEventHandler("onClientElementStreamIn", root,
	function()
		if getElementType(source) == "ped" or getElementType(source) == "player" then
			local anim = getElementData(source, "anim")
			if anim ~= false then
				setElementFrozen(source, true)
				setElementCollisionsEnabled(source, false)
				setPedAnimation(source, anim[1], anim[2], 50, true, false, false, true)
			end
		end
	end
)

function getPositionFromElementOffset(element,offX,offY,offZ)
	local m = getElementMatrix ( element )  -- Get the matrix
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	return x, y, z                               -- Return the transformed point
end