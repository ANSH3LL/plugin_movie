local composer = require('composer')
local movie = require('plugin.movie')

local volume = 1
local header, nametag, footer, movierect
local playbtn, pausebtn, stopbtn, backbtn, info, counter

local centerX, centerY = display.contentCenterX, display.contentCenterY
local safeX, safeY = display.safeScreenOriginX, display.safeScreenOriginY
local width, height = display.safeActualContentWidth, display.safeActualContentHeight

local function movieListener(event)
    if event.phase == 'stopped' then
        print('Video watched to end? ', event.completed)
        info.text = event.completed and 'Watched to end' or 'Stopped halfway'
        info.isVisible = true
        info:toFront()
    end
end

local function keyListener(event)
    if event.phase == 'up' then
        if event.keyName == 'space' then
            if movierect.playing then
                movierect.pause()
                --
                pausebtn.isVisible = false
                playbtn.isVisible = true
            else
                movierect.play()
                --
                pausebtn.isVisible = true
                playbtn.isVisible = false
            end
        elseif event.keyName == 'escape' then
            movierect.stop()
            --
            pausebtn.isVisible = false
            playbtn.isVisible = false
        elseif event.keyName == 'f' then
            if native.getProperty('windowMode') == 'fullscreen' then
                native.setProperty('windowMode', 'normal')
            else
                native.setProperty('windowMode', 'fullscreen')
            end
        elseif event.keyName == 't' then
            counter.text = movierect.texture.currentTime .. 's'
        elseif event.keyName == 'up' then
            volume = volume + 0.1
            --
            if volume >= 1 then
                volume = 1
            end
            --
            audio.setVolume(volume, {channel = movierect.channel})
        elseif event.keyName == 'down' then
            volume = volume - 0.1
            --
            if volume <= 0 then
                volume = 0
            end
            --
            audio.setVolume(volume, {channel = movierect.channel})
        end
    end
end

local function playListener(event)
    if event.phase == 'ended' then
        movierect.play()
        --
        pausebtn.isVisible = true
        playbtn.isVisible = false
    end
    return true
end

local function pauseListener(event)
    if event.phase == 'ended' then
        movierect.pause()
        --
        pausebtn.isVisible = false
        playbtn.isVisible = true
    end
    return true
end

local function stopListener(event)
    if event.phase == 'ended' then
        movierect.stop()
        --
        pausebtn.isVisible = false
        playbtn.isVisible = false
    end
    return true
end

local function backListener(event)
    if event.phase == 'ended' then
        movierect.stop()
        composer.gotoScene('scenes.menu', {effect = 'fade', time = 300})
    end
    return true
end

local function timeListener(event)
    if event.phase == 'ended' then
        counter.text = movierect.texture.currentTime .. 's'
    end
    return true
end

local function sndupListener(event)
    if event.phase == 'ended' then
        volume = volume + 0.1
        --
        if volume >= 1 then
            volume = 1
        end
        --
        audio.setVolume(volume, {channel = movierect.channel})
    end
    return true
end

local function snddownListener(event)
    if event.phase == 'ended' then
        volume = volume - 0.1
        --
        if volume <= 0 then
            volume = 0
        end
        --
        audio.setVolume(volume, {channel = movierect.channel})
    end
    return true
end

local scene = composer.newScene()

function scene:create(event)
    local sceneGroup = self.view
    --
    header = display.newRect(centerX, safeY + 25, width, 50)
    header:setFillColor(0, 1, 1, 0.3)
    --
    backbtn = display.newImageRect('icons/back.png', 32, 32)
    backbtn.x, backbtn.y = safeX + 25, safeY + 25
    backbtn:addEventListener('touch', backListener)
    --
    nametag = display.newText(
        {
            x = safeX + 250,
            y = safeY + 25,
            fontSize = 20,
            align = 'left',
            font = native.systemFont,
            text = 'Simple video player [sample_video.ogv]'
        }
    )
    --
    info = display.newText(
        {
            x = centerX,
            y = centerY,
            fontSize = 30,
            align = 'center',
            font = native.systemFont,
            text = '?'
        }
    )
    --
    footer = display.newRect(centerX, safeY + height - 25, width, 50)
    footer:setFillColor(0, 0, 0, 0.3)
    --
    playbtn = display.newImageRect('icons/play.png', 32, 32)
    playbtn.x, playbtn.y = safeX + 25, safeY + height - 25
    playbtn:addEventListener('touch', playListener)
    --
    pausebtn = display.newImageRect('icons/pause.png', 32, 32)
    pausebtn.x, pausebtn.y = safeX + 25, safeY + height - 25
    pausebtn:addEventListener('touch', pauseListener)
    --
    stopbtn = display.newImageRect('icons/stop.png', 37, 37)
    stopbtn.x, stopbtn.y = safeX + 75, safeY + height - 25
    stopbtn:addEventListener('touch', stopListener)
    --
    counter = display.newText(
        {
            x = safeX + 150,
            y = safeY + height - 25,
            fontSize = 20,
            align = 'left',
            font = native.systemFont,
            text = '0s'
        }
    )
    counter:addEventListener('touch', timeListener)
    --
    soundup = display.newImageRect('icons/volumeup.png', 37, 37)
    soundup.x, soundup.y = safeX + width - 50, safeY + height - 25
    soundup:addEventListener('touch', sndupListener)
    --
    sounddown = display.newImageRect('icons/volumedown.png', 37, 37)
    sounddown.x, sounddown.y = safeX + width - 100, safeY + height - 25
    sounddown:addEventListener('touch', snddownListener)
    --
    sceneGroup:insert(header)
    sceneGroup:insert(backbtn)
    sceneGroup:insert(nametag)
    sceneGroup:insert(info)
    --
    sceneGroup:insert(footer)
    sceneGroup:insert(playbtn)
    sceneGroup:insert(pausebtn)
    sceneGroup:insert(stopbtn)
    sceneGroup:insert(counter)
    sceneGroup:insert(soundup)
    sceneGroup:insert(sounddown)
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
    --
    if phase == 'will' then
        movierect = movie.newMovieRect(
            {
                x = centerX,
                y = centerY,
                width = 960,
                height = 540,
                channel = 3,
                listener = movieListener,
                filename = 'videos/sample_video.ogv'
            }
        )
        sceneGroup:insert(movierect)
    elseif phase == 'did' then
        info.isVisible = false
        movierect:toBack()
        --
        playbtn.isVisible = true
        pausebtn.isVisible = false
        --
        Runtime:addEventListener('key', keyListener)
    end
end

function scene:hide(event)
    local phase = event.phase
    --
    if phase == 'will' then
        movierect.stop()
    elseif phase == 'did' then
        Runtime:removeEventListener('key', keyListener)
    end
end

function scene:destroy(event)
end

-------------------------------------------------------------------------------------
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)
-------------------------------------------------------------------------------------

return scene
