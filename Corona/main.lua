local composer = require('composer')

local platform = system.getInfo('platform')
local environment = system.getInfo('environment')

display.setStatusBar(display.HiddenStatusBar)

if platform == 'android' and environment == 'device' then
    if system.getInfo('androidApiLevel') >= 19 then -- KitKat and later
        native.setProperty('androidSystemUiVisibility', 'immersiveSticky')
    else
        native.setProperty('androidSystemUiVisibility', 'lowProfile')
    end
end

local status = display.newText(
    {
        x = display.contentCenterX,
        y = display.contentCenterY,
        text = 'Loading...',
        fontSize = 30
    }
)

timer.performWithDelay(1000,
    function()
        status:removeSelf()
        status = nil
        --
        composer.gotoScene('scenes.menu')
    end
)

if platform == 'android' then
    Runtime:addEventListener('key',
        function(event)
            if event.keyName == 'back' and event.phase == 'up' then
                if composer.getSceneName('current') == 'scenes.menu' then
                    native.requestExit()
                else
                    composer.gotoScene('scenes.menu', {effect = 'fade', time = 300})
                end
            end
            return true
        end
    )
end
