local widget = require('widget')
local composer = require('composer')

local scene = composer.newScene()

local title, scene1, scene2
local scene3, scene4, scene5

function scene:create(event)
    local sceneGroup = self.view
    --
    title = display.newText(
        {
            x = display.contentCenterX,
            y = display.contentCenterY * 0.25,
            text = 'Movie plugin examples',
            fontSize = 40
        }
    )
    --
    scene1 = widget.newButton(
        {
            x = display.contentCenterX * 0.75,
            y = display.contentCenterY * 0.80,
            label = 'Simple video player',
            shape = 'roundedRect',
            cornerRadius = 5,
            onRelease = function() composer.gotoScene('scenes.player') end,
            labelColor = {
                default = {1, 1, 1},
                over = {0, 0, 0}
            },
            fillColor = {
                default = {0.404, 0.008, 0.654},
                over = {0.565, 0.008, 0.918}
            }
        }
    )
    --
    scene2 = widget.newButton(
        {
            x = display.contentCenterX * 0.75,
            y = display.contentCenterY * 1.20,
            label = 'Audio/Video sync test',
            shape = 'roundedRect',
            cornerRadius = 5,
            onRelease = function() composer.gotoScene('scenes.synctest') end,
            labelColor = {
                default = {1, 1, 1},
                over = {0, 0, 0}
            },
            fillColor = {
                default = {0.404, 0.008, 0.654},
                over = {0.565, 0.008, 0.918}
            }
        }
    )
    --
    scene3 = widget.newButton(
        {
            x = display.contentCenterX * 1.25,
            y = display.contentCenterY * 0.80,
            label = 'Loop test (a / v)',
            shape = 'roundedRect',
            cornerRadius = 5,
            onRelease = function() composer.gotoScene('scenes.advert') end,
            labelColor = {
                default = {1, 1, 1},
                over = {0, 0, 0}
            },
            fillColor = {
                default = {0.404, 0.008, 0.654},
                over = {0.565, 0.008, 0.918}
            }
        }
    )
    --
    scene4 = widget.newButton(
        {
            x = display.contentCenterX * 1.25,
            y = display.contentCenterY * 1.20,
            label = 'Loop test (no audio)',
            shape = 'roundedRect',
            cornerRadius = 5,
            onRelease = function() composer.gotoScene('scenes.tunnel') end,
            labelColor = {
                default = {1, 1, 1},
                over = {0, 0, 0}
            },
            fillColor = {
                default = {0.404, 0.008, 0.654},
                over = {0.565, 0.008, 0.918}
            }
        }
    )
    --
    scene5 = widget.newButton(
        {
            x = display.contentCenterX,
            y = display.contentCenterY,
            label = 'Loop test (no video)',
            shape = 'roundedRect',
            cornerRadius = 5,
            onRelease = function() composer.gotoScene('scenes.sound') end,
            labelColor = {
                default = {1, 1, 1},
                over = {0, 0, 0}
            },
            fillColor = {
                default = {0.404, 0.008, 0.654},
                over = {0.565, 0.008, 0.918}
            }
        }
    )
    --
    sceneGroup:insert(title)
    sceneGroup:insert(scene1)
    sceneGroup:insert(scene2)
    sceneGroup:insert(scene3)
    sceneGroup:insert(scene4)
    sceneGroup:insert(scene5)
end

function scene:show(event)
end

function scene:hide(event)
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
