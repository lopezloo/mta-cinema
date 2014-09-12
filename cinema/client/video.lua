-- PURPOSE: Playing videos on cinema room screens.

local video = {
	shader = dxCreateShader("replaceTexture.fx"),
	browser,
	fullscreen
}

local screenTextures = {
	[7901] = "bobobillboard1",
	[2596] = "cj_tv_screen",
	[2296] = "cj_tv_screen",
	[16377] = "cj_tv_screen",
	[2700] = "cj_tv_screen"
}

if not video.shader then
	outputChatBox("CRITICAL ERROR: #F2F2F2Can't create shader. You will not able to see videos properly. (Free memory for MTA: " .. dxGetStatus().VideoMemoryFreeForMTA .. " MB)", 255, 0, 0, true)
end

function playVideo(room, seconds)
	local vid, screens, url = getElementData(room, "video"), getElementData(room, "screens")
	if not screens then
		outputChatBox("ERROR: Room doesn't have assigned any screen.")
		return
	end

	if vid then
		if vid[1] == "yt" then
			url = "http://youtube.com/tv/#/watch?v=" .. vid[2] .. "&mode=transport"
			if seconds then
				outputChatBox("Passed seconds: " .. seconds)
				url = url .. "&t=" .. seconds .. "s" -- &t=120s (tv and normal link)
			end
		elseif vid[1] == "vimeo" then
			url = "http://player.vimeo.com/video/" .. vid[2] .. "?autoplay=1"
			if seconds then
				outputChatBox("Passed seconds: " .. seconds)
				url = url .. "&#t=0m" .. seconds .. "s"
			end
		elseif vid[1] == "dailymotion" then
			url = "http://dailymotion.com/embed/video/" .. vid[2] .. "?autoplay=1&html=1&info=0&related=0&quality=480"
			if seconds then
				outputChatBox("Passed seconds: " .. seconds)
				url = url .. "&start=" .. seconds
			end
		elseif vid[1] == "soundcloud" then
			--url = "http://w.soundcloud.com/player/?url=http://api.soundcloud.com/tracks/" .. vid[2] .. "&auto_play=true&hide_related=true&visual=true&show_comments=false&buying=false&liking=false&download=false&sharing=false"
			--url = "http://w.soundcloud.com/player/?url=http://api.soundcloud.com/tracks/146340923&auto_play=true&visual=true"
			--  no time parameter :(
			url = "http://soundcloud.com/" .. vid[2] -- time parameter but no autoplay .. wtf
			if seconds then
				outputChatBox("Passed seconds: " .. seconds)
				url = url .. "#t=" .. seconds .. "s"
			end
		elseif vid[1] == "twitch" then
			url = "http://twitch.tv/" .. vid[2] .. "/popout"
		end
	else
		url = "http://redknife.tk/mta/cinema/novideo.html"
	end
	
	if not isElement(video.browser) then
		video.browser = createBrowser(sX, sY, false)
		addEventHandler("onClientRender", root, updateVideoBrowser)
	end

	outputDebugString("Trying to load url: " .. url)
	--[[if isBrowserURLBlocked(url) then -- and url ~= "html/novideo.html" -- bugged in 
		outputChatBox("You don't allowed to view this site, please use /permissions (" .. url .. ")")
	else
		loadBrowserURL(video.browser, url)
	end]]--
	loadBrowserURL(video.browser, url)

	dxSetShaderValue(video.shader, "Tex0", video.browser)
	for k, v in pairs(screens) do
		--outputChatBox(tostring(getElementModel(v)) .. " = " .. tostring(screenTextures[getElementModel(v)]))
		engineApplyShaderToWorldTexture(video.shader, screenTextures[getElementModel(v)], v) -- bobobillboard1 , cj_tv_screen , drvin_screen
	end
end

function stopVideo(room)
	if isElement(video.browser) then
		outputChatBox("stopVideo")
		if not room then room = getElementData(localPlayer, "colshape") end
		if isElement(room) then
			local screens = getElementData(room, "screens")
			if screens then
				for k, v in pairs(screens) do
					engineRemoveShaderFromWorldTexture(video.shader, screenTextures[getElementModel(v)], v)
				end
			end

			if video.fullscreen then
				removeEventHandler("onClientRender", root, renderVideoOnFullscreen)
				video.fullscreen = false
			end
			removeEventHandler("onClientRender", root, updateVideoBrowser)
			destroyElement(video.browser)
		end		
	end
end
addEventHandler("onClientPlayerWasted", localPlayer, stopVideo)

function updateVideoBrowser()
	updateBrowser(video.browser)
end

function renderVideoOnFullscreen()
	dxDrawImage(0, 0, sX, sY, video.browser)
end

function toggleFullscreen()
	if isElement(video.browser) then
		if not video.fullscreen then
			addEventHandler("onClientRender", root, renderVideoOnFullscreen)
		else
			removeEventHandler("onClientRender", root, renderVideoOnFullscreen)
		end
		video.fullscreen = not video.fullscreen
	end
end

bindKey("O", "down", -- show video controls
	function()
		if isElement(video.browser) and not request.searchingVideo then
			injectBrowserMouseMove(video.browser, 1, 1)
			injectBrowserMouseMove(video.browser, 0, 0)
		end
	end
)