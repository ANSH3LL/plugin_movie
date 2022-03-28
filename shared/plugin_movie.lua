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
    local loop = {
        iterations = 1,
        _stop = false,
        playing = false,
        listener = opts.listener
    }
    --
    loop.callback = function(event)
        if loop._stop then return end
        --
        loop.iterations = loop.iterations + 1
        --
        if loop.iterations % 2 == 0 then
            loop.two.isVisible = true
            loop.two.play()
            --
            timer.performWithDelay(300, loop.one.dispose)
            timer.performWithDelay(500,
                function()
                    loop.one = lib.newMovieRect(loop.options1)
                    loop.one.isVisible = false
                end
            )
        else
            loop.one.isVisible = true
            loop.one.play()
            --
            timer.performWithDelay(300, loop.two.dispose)
            timer.performWithDelay(500,
                function()
                    loop.two = lib.newMovieRect(loop.options2)
                    loop.two.isVisible = false
                end
            )
        end
        --
        if loop.listener then
            loop.listener(
                {
                    name = 'movie',
                    phase = 'loop',
                    iterations = loop.iterations
                }
            )
        end
    end
    --
    loop.options1 = {
        x = opts.x, y = opts.y,
        listener = loop.callback,
        preserve = true, channel = opts.channel1,
        width = opts.width, height = opts.height,
        filename = opts.filename, baseDir = opts.baseDir
    }
    --
    loop.options2 = copy(loop.options1)
    loop.options2.channel = opts.channel2
    --
    loop.one = lib.newMovieRect(loop.options1)
    loop.two = lib.newMovieRect(loop.options2)
    loop.two.isVisible = false
    --
    loop.rect = function()
        return loop.iterations % 2 == 0 and loop.two or loop.one
    end
    --
    loop.play = function()
        if loop.playing then return end
        --
        loop.rect().play()
        loop.playing = true
    end
    --
    loop.pause = function()
        if not loop.playing then return end
        --
        loop.playing = false
        loop.rect().pause()
    end
    --
    loop.stop = function()
        if loop._stop then return end
        --
        loop._stop = true
        loop.playing = false
        --
        loop.one.stop()
        loop.two.stop()
        --
        loop.one.dispose()
        loop.two.dispose()
        --
        if loop.listener then
            loop.listener(
                {
                    name = 'movie',
                    phase = 'stopped',
                    completed = loop.iterations > 1 and true or false
                }
            )
        end
    end
    --
    return loop
end

-- Return an instance
return lib
