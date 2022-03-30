local composer = require('composer')
local movie = require('plugin.movie')

local header, nametag, footer, movierect
local playbtn, stopbtn, backbtn

local centerX, centerY = display.contentCenterX, display.contentCenterY
local safeX, safeY = display.safeScreenOriginX, display.safeScreenOriginY
local width, height = display.safeActualContentWidth, display.safeActualContentHeight

local function movieListener(event)
    if event.phase == 'stopped' then
        print('Video watched to end? ', event.completed)
    end
end

local function keyListener(event)
    if event.phase == 'up' then
        if event.keyName == 'space' then
            if not movierect.playing then
                movierect.play()
                --
                playbtn.isVisible = false
            end
        elseif event.keyName == 'escape' then
            movierect.stop()
            --
            playbtn.isVisible = false
        elseif event.keyName == 'f' then
            if native.getProperty('windowMode') == 'fullscreen' then
                native.setProperty('windowMode', 'normal')
            else
                native.setProperty('windowMode', 'fullscreen')
            end
        end
    end
end

local function playListener(event)
    if event.phase == 'ended' then
        movierect.play()
        --
        playbtn.isVisible = false
    end
    return true
end

local function stopListener(event)
    if event.phase == 'ended' then
        movierect.stop()
        --
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
            text = 'Audio/Video sync test [av_sync_test.ogv]'
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
    stopbtn = display.newImageRect('icons/stop.png', 37, 37)
    stopbtn.x, stopbtn.y = safeX + 75, safeY + height - 25
    stopbtn:addEventListener('touch', stopListener)
    --
    sceneGroup:insert(header)
    sceneGroup:insert(backbtn)
    sceneGroup:insert(nametag)
    --
    sceneGroup:insert(footer)
    sceneGroup:insert(playbtn)
    sceneGroup:insert(stopbtn)
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
                filename = 'videos/av_sync_test.ogv'
            }
        )
        sceneGroup:insert(movierect)
    elseif phase == 'did' then
        movierect:toBack()
        --
        playbtn.isVisible = true
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
