-- PURPOSE: Managing request browser, requesting videos.

guiSetInputMode("no_binds_when_editing")
request = {
	pX = (sX-1024)/2, pY = (sY-768)/2,

	window = guiCreateWindow(0.02, 0.25, 0.22, 0.60, "Requests", true),
	browser = createBrowser(1024, 768, false, false), -- external request browser
	searchingVideo
}

request.buttons = {
	guiCreateButton(request.pX+1024-150, request.pY+768-75, 115.2, 54, "REQUEST", false), -- 0.76, 0.85, 0.08, 0.06
	guiCreateButton(request.pX+25, request.pY+768-75, 115.2, 54, "CANCEL", false), -- 0.15, 0.85, 0.08, 0.06
	guiCreateButton(request.pX+150, request.pY+768-75, 57.6, 54, "HOME", false) -- 0.25, 0.84, 0.04, 0.06
}
request.gridlist = guiCreateGridList(0.03, 0.04, 0.94, 0.67, true, request.window)

for k, v in pairs(request.buttons) do
	guiSetVisible(v, false)
	guiSetFont(v, "default-bold-small")
	guiSetProperty(v, "NormalTextColour", "FFCD0000")
end

request.rbuttons = {
	guiCreateButton(0.04, 0.72, 0.45, 0.07, "Request video", true, request.window),
	guiCreateButton(0.04, 0.81, 0.93, 0.07, "Toggle fullscreen", true, request.window),
	guiCreateButton(0.52, 0.72, 0.45, 0.07, "Vote to skip current video", true, request.window),
	guiCreateButton(0.04, 0.90, 0.45, 0.07, "Vote -1", true, request.window),
	guiCreateButton(0.51, 0.90, 0.45, 0.07, "Vote +1", true, request.window)
}

guiSetVisible(request.window, false)
guiWindowSetSizable(request.window, false)
guiGridListSetColumnWidth(request.gridlist, guiGridListAddColumn(request.gridlist, "Title", 0.3), 0.5, true)
guiGridListSetColumnWidth(request.gridlist, guiGridListAddColumn(request.gridlist, "Time", 0.3), 0.2, true)
guiGridListSetColumnWidth(request.gridlist, guiGridListAddColumn(request.gridlist, "Votes", 0.3), 0.2, true)
guiGridListSetSortingEnabled(request.gridlist, false)
guiSetEnabled(request.rbuttons[4], false)
guiSetEnabled(request.rbuttons[5], false)
--

loadBrowserURL(request.browser, "http://redknife.tk/mta/cinema/request.html") -- todo: loading url in external mode should be after acceptation, no before

addCommandHandler("req", -- debug cmd
	function(cmd, theType, vid)
		if (theType == "yt" or theType == "vimeo") and vid and getElementData(localPlayer, "colshape") then
			outputChatBox("Requesting " .. theType .. " video with url: " .. tostring(vid))
			triggerServerEvent("requestVideo", root, theType, vid)
		end
	end
)

function renderRequestBrowser()
	dxDrawRectangle(request.pX-10, request.pY-10, 1044, 788, tocolor(255, 0, 0, 150))
	dxDrawImage(request.pX, request.pY, 1024, 768, request.browser)
end

local videoGetString = {
	-- mode, url, missing letters
	{"yt", "youtube.com/watch?", 2},
	{"vimeo", "vimeo.com/"}
	--{"hitbox", "hitbox.tv/"} -- todo
	--{"twitch", "twitch.tv/"} -- only in SSL
	--{"dailymotion", "dailymotion.com/video/"} -- only in SSL
}

addEventHandler("onClientGUIClick", root,
	function(button)
		if button == "left" then
			if source == request.buttons[1] then -- requesting video
				local url = getBrowserURL(request.browser)
				outputChatBox("Request url: " .. tostring(url))
				for k, v in pairs(videoGetString) do
					local a = string.find(url, v[2])
					if a then -- if video service url pattern found
						if v[3] then 
							a = a + v[3]
						end

						url = string.sub(url, a + string.len(v[2]))
						local urlEnd = string.find(url, "&")
						if urlEnd then
							url = string.sub(url, 1, urlEnd - 1)
						end
						outputChatBox("Requesting video (" .. v[1] .. ") with url: " .. url)
						triggerServerEvent("requestVideo", root, v[1], url)
						break
					end
				end
			elseif source == request.buttons[2] or source == request.rbuttons[1] then -- cancel request or start request button
				if not request.searchingVideo then -- show request browser
					showCursor(true)
					guiSetVisible(request.window, false)
					guiSetVisible(request.buttons[1], true)
					guiSetVisible(request.buttons[2], true)
					guiSetVisible(request.buttons[3], true)

					addEventHandler("onClientRender", root, renderRequestBrowser)
					addEventHandler("onClientCursorMove", root, onCursorMove)
					addEventHandler("onClientClick", root, onClick)
					addEventHandler("onClientKey", root, onKey)
					toggleAllControls(false, false, true)
					focusBrowser(request.browser)
				else -- hide request browser
					if not guiGetVisible(request.window) then
						showCursor(false)
					end
					guiSetVisible(request.buttons[1], false)
					guiSetVisible(request.buttons[2], false)
					guiSetVisible(request.buttons[3], false)
				
					removeEventHandler("onClientRender", root, renderRequestBrowser)
					removeEventHandler("onClientCursorMove", root, onCursorMove)
					removeEventHandler("onClientClick", root, onClick)
					removeEventHandler("onClientKey", root, onKey)

					toggleAllControls(true, false, true)
				end
				request.searchingVideo = not request.searchingVideo
			elseif source == request.buttons[3] then
				loadBrowserURL(request.browser, "http://redknife.tk/mta/cinema/request.html")
			elseif source == request.rbuttons[2] then
				toggleFullscreen()
			elseif source == request.rbuttons[3] and getElementData(source, "votedToSkip") == false then
				triggerServerEvent("voteSkip", root, 1)
			end
		end
	end
)

addCommandHandler("menu", -- request menu/gui open/close
	function()
		if isElement(getElementData(localPlayer, "colshape")) then
			local a = guiGetVisible(request.window)
			guiSetVisible(request.window, not a)
			
			if not request.searchingVideo then
				showCursor(not a)
			end
		end
	end
)
bindKey("B", "down", "menu")

-- REQUEST BROWSER INTERACTION
addEventHandler("onClientMouseEnter", root,
	function()
		if request.searchingVideo and (source == request.buttons[1] or source == request.buttons[2] or source == request.buttons[3]) then
			removeEventHandler("onClientClick", root, onClick) -- prevent clicking on browser while player want click button
		end
	end
)

addEventHandler("onClientMouseLeave", root,
	function()
		if request.searchingVideo and (source == request.buttons[1] or source == request.buttons[2] or source == request.buttons[3]) then
			addEventHandler("onClientClick", root, onClick)
		end
	end
)

function onCursorMove(relativeX, relativeY, absoluteX, absoluteY)
	injectBrowserMouseMove(request.browser, absoluteX - request.pX, absoluteY - request.pY)
end

function onClick(button, state)
	if button == "left" then
		if state == "down" then
			injectBrowserMouseDown(request.browser, "left")
		else
			injectBrowserMouseUp(request.browser, "left")
		end
	end
end

function onKey(button, pressed)	
	if button == "mouse_wheel_down" then
		injectBrowserMouseWheel(request.browser, -80, 0)
	elseif button == "mouse_wheel_up" then
		injectBrowserMouseWheel(request.browser, 80, 0)
	end	
end