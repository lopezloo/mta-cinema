sX, sY = guiGetScreenSize()

local video = {
	shader = dxCreateShader("replaceTexture.fx"),
	target = dxCreateRenderTarget(sX, sY),
	browser = createBrowser(sX, sY),
	fullscreen
}

requestBrowserPages( { "youtube.com", "vimeo.com", "player.vimeo.com", "twitch.tv", "redknife.net" } )

local screenTextures = {
	[7901] = "bobobillboard1",
	[2596] = "cj_tv_screen",
	[2296] = "cj_tv_screen",
	[16377] = "cj_tv_screen",
	[2700] = "cj_tv_screen"
}

function playVideo(room, seconds)
	local vid = getElementData(room, "video")

	local screens = getElementData(room, "screens")
	if not screens then
		outputChatBox("ERROR: Room doesn't have assigned any screen.")
		return
	end

	local url
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
		elseif vid[1] == "twitch" then
			url = "http://twitch.tv/" .. vid[2] .. "/popout"
			--url = "http://twitch.tv/" .. vid[2] .. "/hls"
		end
	else
		outputChatBox("no video in this room bro")
		url = "http://redknife.net/mta/cinema/novideo.html"
	end
	
	if not isElement(video.browser) then
		video.browser = createBrowser(sX, sY)
		addEventHandler("onClientRender", root, renderVideo)
	end
	loadBrowserURL(video.browser, url)
	outputChatBox("Loading URL: " .. url)

	dxSetShaderValue(video.shader, "Tex0", video.target)
	for k, v in pairs(screens) do
		outputChatBox(tostring(getElementModel(v)) .. " = " .. tostring(screenTextures[getElementModel(v)]))
		engineApplyShaderToWorldTexture(video.shader, screenTextures[getElementModel(v)], v) -- bobobillboard1 , cj_tv_screen , drvin_screen
	end
end

function stopVideo(room)
	if isElement(video.browser) then
		outputChatBox("stopVideo")
		removeEventHandler("onClientRender", root, renderVideo)
		--loadBrowserURL(video.browser, "") -- try to unload current video

		if not room then room = getElementData(localPlayer, "colshape") end
		if isElement(room) then
			local screens = getElementData(room, "screens")
			if screens then
				for k, v in pairs(screens) do
					engineRemoveShaderFromWorldTexture(video.shader, screenTextures[getElementModel(v)], v)
				end
			end
			destroyElement(video.browser)
		end
	end
end

function renderVideo()
	updateBrowser(video.browser)

	dxSetRenderTarget(video.target)
	dxDrawImage(0, 0, sX, sY, video.browser)
	dxSetRenderTarget()
end

function renderVideoOnFullscreen()
	updateBrowser(video.browser)
	dxDrawImage(0, 0, sX, sY, video.browser)
end

function toggleFullscreen()
	if isElement(video.browser) then
		if not fullscreen then
			removeEventHandler("onClientRender", root, renderVideo)
			addEventHandler("onClientRender", root, renderVideoOnFullscreen)
		else
			removeEventHandler("onClientRender", root, renderVideoOnFullscreen)
			addEventHandler("onClientRender", root, renderVideo)
		end
		fullscreen = not fullscreen
	end
end

bindKey("O", "down", -- show controls, not always work with vimeo (?)
	function()
		if isElement(video.browser) then
			injectBrowserMouseMove(video.browser, 0, 0)
		end
	end
)