local Library = require('CoronaLibrary')

local function copy(table)
    local dst = {}
    for k, v in pairs(table) do
        if type(v) == 'table' then
            dst[k] = copy(v)
        else
            dst[k] = v
        end
    end
    return dst
end

-- Create stub library
local lib = Library:new(
    {
        name = 'plugin.movie',
        publisherId = 'com.ansh3ll'
    }
)

-- DIY
function lib.newMovieTexture(opts)
    local path = system.pathForFile(opts.filename, opts.baseDir or system.ResourceDirectory)
    local source = audio.getSourceFromChannel(opts.channel or audio.findFreeChannel())
    return lib._newMovieTexture(path, source)
end

-- Plug-n-play
function lib.newMovieRect(opts)
    local texture = lib.newMovieTexture(opts)
    local rect = display.newImageRect(texture.filename, texture.baseDir, opts.width, opts.height)
    rect.texture, rect.channel = texture, opts.channel
    --
    rect.x, rect.y = opts.x, opts.y
    rect._preserve = opts.preserve
    rect.listener = opts.listener
    --
    rect._delta = 0
    rect.playing = false
    rect._complete = false
    --
    rect.update = function()
        local currtime = system.getTimer()
        --
        if rect.playing then
            if rect._prevtime then
                rect._delta = currtime - rect._prevtime
            end
            --
            rect.texture:update(rect._delta)
            rect.texture:invalidate()
            --
            if not rect.texture.isActive then
                rect._complete = true
                rect.stop()
            end
        end
        --
        rect._prevtime = currtime
    end
    --
    rect.play = function()
        if rect.playing then return end
        --
        rect.texture:play()
        rect.playing = true
        --
        Runtime:addEventListener('enterFrame', rect.update)
    end
    --
    rect.pause = function()
        if not rect.playing then return end
        --
        rect.playing = false
        rect.texture:pause()
    end
    --
    rect.stop = function()
        Runtime:removeEventListener('enterFrame', rect.update)
        --
        rect.playing = false
        rect.texture:stop()
        --
        if rect.listener then
            rect.listener(
                {
                    name = 'movie',
                    phase = 'stopped',
                    completed = rect._complete
                }
            )
        end
        --
        if rect._preserve then return end
        --
        rect.dispose()
    end
    --
    rect.dispose = function()
        if rect.playing then return end
        --
        timer.performWithDelay(100,
            function()
                if rect.texture then
                    rect.texture:releaseSelf()
                    rect.texture = nil
                end
                --
                rect:removeSelf()
            end
        )
    end
    --
    return rect
end

-- Looping video
function lib.newMovieLoop(opts)
    local group = display.newGroup()
    --
    group._stop = false,
    group.iterations = 1,
    group.playing = false,
    group.listener = opts.listener
    --
    group.callback = function(event)
        if group._stop then return end
        --
        group.iterations = group.iterations + 1
        --
        if group.iterations % 2 == 0 then
            group.two.isVisible = true
            group.two.play()
            --
            timer.performWithDelay(300,
                function()
                    group.one.isVisible = false
                    group.one.texture:releaseSelf()
                    group.one.texture = lib.newMovieTexture(group.options1)
                    --
                    group.one.fill = {
                        type = 'image',
                        filename = group.one.texture.filename,
                        baseDir = group.one.texture.baseDir
                    }
                end
            )
        else
            group.one.isVisible = true
            group.one.play()
            --
            timer.performWithDelay(300,
                function()
                    group.two.isVisible = false
                    group.two.texture:releaseSelf()
                    group.two.texture = lib.newMovieTexture(group.options2)
                    --
                    group.two.fill = {
                        type = 'image',
                        filename = group.two.texture.filename,
                        baseDir = group.two.texture.baseDir
                    }
                end
            )
        end
        --
        if group.listener then
            group.listener(
                {
                    name = 'movie',
                    phase = 'loop',
                    iterations = group.iterations
                }
            )
        end
    end
    --
    group.options1 = {
        x = opts.x, y = opts.y,
        listener = group.callback,
        preserve = true, channel = opts.channel1,
        width = opts.width, height = opts.height,
        filename = opts.filename, baseDir = opts.baseDir
    }
    --
    group.options2 = copy(group.options1)
    group.options2.channel = opts.channel2
    --
    group.one = lib.newMovieRect(group.options1)
    group.two = lib.newMovieRect(group.options2)
    group.two.isVisible = false
    --
    group:insert(group.one)
    group:insert(group.two)
    --
    group.rect = function()
        return group.iterations % 2 == 0 and group.two or group.one
    end
    --
    group.play = function()
        if group.playing then return end
        --
        group.rect().play()
        group.playing = true
    end
    --
    group.pause = function()
        if not group.playing then return end
        --
        group.playing = false
        group.rect().pause()
    end
    --
    group.stop = function()
        if group._stop then return end
        --
        group._stop = true
        group.playing = false
        --
        group.one.stop()
        group.two.stop()
        --
        group.one.dispose()
        group.two.dispose()
        --
        group:removeSelf()
        --
        if group.listener then
            group.listener(
                {
                    name = 'movie',
                    phase = 'stopped',
                    completed = group.iterations > 1 and true or false
                }
            )
        end
    end
    --
    return group
end

-- Return an instance
return lib
