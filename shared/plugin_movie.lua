local Library = require('CoronaLibrary')

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
    local channel = opts.channel or audio.findFreeChannel()
    local source = audio.getSourceFromChannel(channel)
    local loop = opts.loop or false
    --
    return lib._newMovieTexture(path, source, loop), channel
end

-- Plug-n-play
function lib.newMovieRect(opts)
    local listener = opts.listener
    local texture, channel = lib.newMovieTexture(opts)
    --
    local rect = display.newImageRect(texture.filename, texture.baseDir, opts.width, opts.height)
    rect.texture, rect.channel = texture, channel
    rect.x, rect.y = opts.x, opts.y
    --
    rect._playing = false
    rect._complete = false
    rect._preserve = opts.preserve or false
    --
    rect._play = function()
        local ctime, delta = system.getTimer(), 0
        --
        if rect._playing then
            if rect._ptime then
                delta = ctime - rect._ptime
            end
            --
            rect.texture:update(delta)
            rect.texture:invalidate()
            --
            if not rect.texture.isActive then
                rect._complete = true
                rect.stop()
            end
        end
        --
        rect._ptime = ctime
    end
    --
    rect.play = function()
        if rect._playing then return end
        --
        rect.texture:play()
        rect._playing = true
        --
        Runtime:addEventListener('enterFrame', rect._play)
    end
    --
    rect.pause = function()
        if not rect._playing then return end
        --
        rect._playing = false
        rect.texture:pause()
    end
    --
    rect.stop = function()
        Runtime:removeEventListener('enterFrame', rect._play)
        --
        rect.texture:stop()
        --
        timer.performWithDelay(100,
            function()
                if not rect._preserve then
                    rect.texture:releaseSelf()
                    rect.texture = nil
                    rect:removeSelf()
                end
                --
                if listener then
                    listener({name = 'movie', phase = 'stopped', completed = rect._complete})
                end
            end
        )
    end
    --
    return rect
end

-- Return an instance
return lib
