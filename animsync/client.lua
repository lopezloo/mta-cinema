function setPedSyncedAnimation(ped, block, anim)
	setElementData(ped, "anim", {block, anim})
end

function resetPedSyncedAnimation(ped)
	setElementData(ped, "anim", false)
end

addEventHandler("onClientElementDataChange", root,
	function(data, oldValue)
		if data == "anim" and (getElementType(source) == "ped" or getElementType(source) == "player") then
			local anim = getElementData(source, "anim")
			if oldValue ~= false and anim == false then
				setPedAnimation(source, "ped", "facanger", 50, true, true, true, true) -- anim reset (when time is 50ms MTA thinks no anim is played so I can't normally reset animation)
			elseif anim ~= false then
				setPedAnimation(source, anim[1], anim[2], 50, true, true, false, true) -- time is 50ms because this allow to move with animation (mta thinks .. up^)
			end
		end
	end
)

addEventHandler("onClientElementStreamIn", root,
	function()
		if getElementType(source) == "ped" or getElementType(source) == "player" then
			local anim = getElementData(source, "anim")
			if anim ~= false then
				setPedAnimation(source, anim[1], anim[2], 50, true, true, false, true)
			end
		end
	end
)