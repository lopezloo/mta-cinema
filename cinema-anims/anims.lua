currentAnim = 1
anims = {
	{"CAR", "Sit_relaxed"},
	{"LOWRIDER", "Tap_hand"},
	{"ped", "CAR_sitp"},
	{"FOOD", "FF_Sit_Loop"},
	{"FOOD", "FF_Die_Bkw"},
	{"INT_OFFICE", "OFF_Sit_Bored_Loop"},
	{"INT_OFFICE", "OFF_Sit_Idle_Loop"},
	{"SUNBATHE", "ParkSit_M_IdleC"},
	{"SUNBATHE", "ParkSit_W_idleA"}
}

bindKey("mouse1", "down",
	function()
		if not startPos and getElementData(localPlayer, "anim") ~= false then
			currentAnim = currentAnim + 1
			if currentAnim > #anims then
				currentAnim = 1
			end
			setElementData(localPlayer, "anim", anims[currentAnim])
		end
	end
)

bindKey("mouse2", "down",
	function()
		if not startPos and getElementData(localPlayer, "anim") ~= false then
			currentAnim = currentAnim - 1
			if currentAnim == 0 then
				currentAnim = #anims
			end
			setElementData(localPlayer, "anim", anims[currentAnim])
		end
	end
)