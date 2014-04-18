request = {
	pX = (sX-1024)/2, pY = (sY-768)/2,

	window = guiCreateWindow(0.02, 0.25, 0.22, 0.60, "Requests", true),
	browser = createBrowser(1024, 768),
	searchingVideo
}

request.buttons = {
	guiCreateButton(request.pX+1024-150, request.pY+768-75, 115.2, 54, "REQUEST", false), -- 0.76, 0.85, 0.08, 0.06
	guiCreateButton(request.pX+25, request.pY+768-75, 115.2, 54, "CANCEL", false) -- 0.15, 0.85, 0.08, 0.06
}

guiSetFont(request.buttons[1], "default-bold-small")
guiSetFont(request.buttons[2], "default-bold-small")
guiSetVisible(request.buttons[1], false)
guiSetVisible(request.buttons[2], false)

guiWindowSetSizable(request.window, false)
request.gridlist = guiCreateGridList(0.03, 0.04, 0.94, 0.67, true, request.window)
guiGridListSetColumnWidth(request.gridlist, guiGridListAddColumn(request.gridlist, "Title", 0.3), 0.5, true)
guiGridListSetColumnWidth(request.gridlist, guiGridListAddColumn(request.gridlist, "Time", 0.3), 0.2, true)
guiGridListSetColumnWidth(request.gridlist, guiGridListAddColumn(request.gridlist, "Votes", 0.3), 0.2, true)

guiGridListSetSortingEnabled(request.gridlist, false)

request.rbuttons = {
	guiCreateButton(0.04, 0.72, 0.45, 0.07, "Request video", true, request.window),
	guiCreateButton(0.04, 0.81, 0.93, 0.07, "Toggle fullscreen", true, request.window),
	guiCreateButton(0.52, 0.72, 0.45, 0.07, "Vote to skip current video", true, request.window),
	guiCreateButton(0.04, 0.90, 0.45, 0.07, "Vote -1", true, request.window),
	guiCreateButton(0.51, 0.90, 0.45, 0.07, "Vote +1", true, request.window)
}

guiSetVisible(request.window, false)
guiSetEnabled(request.rbuttons[4], false)
guiSetEnabled(request.rbuttons[5], false)

loadBrowserURL(request.browser, "http://youtube.com")

addCommandHandler("req",
	function(cmd, theType, vid)
		if (theType == "yt" or theType == "vimeo" or theType == "twitch") and vid and getElementData(localPlayer, "colshape") then
			outputChatBox("Requesting " .. theType .. " video with url: " .. vid)
			triggerServerEvent("requestVideo", root, theType, vid)
		end
	end
)

function renderRequestBrowser()
	updateBrowser(request.browser)
	dxDrawRectangle(request.pX-10, request.pY-10, 1044, 788, tocolor(255, 0, 0, 150))
	dxDrawImage(request.pX, request.pY, 1024, 768, request.browser)
end

function onCursorMove(relativeX, relativeY, absoluteX, absoluteY)
	injectBrowserMouseMove(request.browser, absoluteX - request.pX, absoluteY - request.pY)
end
 
local btns = {left = 0, middle = 1, right = 2}
function onClick(button, state)
	if state == "down" then
		injectBrowserMouseDown(request.browser, btns[button])
	else
		injectBrowserMouseUp(request.browser, btns[button])
	end
end

function onGUIClick(button, state)
	if button == "left" then
		if source == request.buttons[1] then
			outputChatBox("Requesting video with url: wat?")
			triggerServerEvent("requestVideo", root, "yt", "xMVTKOoy1uk")
		elseif source == request.buttons[2] or source == request.rbuttons[1] then
			if not searchingVideo then
				addEventHandler("onClientRender", root, renderRequestBrowser)	
				addEventHandler("onClientCursorMove", root, onCursorMove)
				addEventHandler("onClientClick", root, onClick)

				showCursor(true)
				guiSetVisible(request.buttons[1], true)
				guiSetVisible(request.buttons[2], true)
			else
				if not guiGetVisible(request.window) then
					showCursor(false)
				end
				guiSetVisible(request.buttons[1], false)
				guiSetVisible(request.buttons[2], false)
				removeEventHandler("onClientRender", root, renderRequestBrowser)
				removeEventHandler("onClientCursorMove", root, onCursorMove)
				removeEventHandler("onClientClick", root, onClick)
			end
			searchingVideo = not searchingVideo
		elseif source == request.rbuttons[2] then
			toggleFullscreen()
		elseif source == request.rbuttons[3] and getElementData(source, "votedToSkip") == false then
			triggerServerEvent("voteSkip", root, 1)
		end
	end
end
addEventHandler("onClientGUIClick", root, onGUIClick)

addCommandHandler("menu",
	function()
		if isElement(getElementData(localPlayer, "colshape")) then
			local a = guiGetVisible(request.window)
			guiSetVisible(request.window, not a)
			
			if not searchingVideo then
				showCursor(not a)
			end
		end
	end
)
bindKey("B", "down", "menu")