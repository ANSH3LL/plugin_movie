# Movie
A video-to-texture plugin for the solar2D (formerly corona-sdk) game engine

# Features
- Plays `Ogg Theora` video files
- Capable of playing videos in a loop
- Renders video to a `CoronaExternalTexture` that can be used to fill a `ShapeObject`, `ImageRect`, etc
- Automatically plays audio in synchronicity with video

# Usage
Add the plugin to your build settings like so:
```lua
plugins = {
    ["plugin.movie"] = {
        publisherId = "com.ansh3ll"
    },
},
```

Simple usage example like so:
```lua
local movie = require('plugin.movie')

local function movieListener(event)
    if event.phase == 'stopped' then
        print('Video watched to end? ', event.completed)
    end
    --
    for k, v in pairs(event) do
        print(k .. ' = ' .. v)
    end
end

local player = movie.newMovieRect(
    {
        x = display.contentCenterX,
        y = display.contentCenterY,
        width = 960,
        height = 540,
        channel = 3,
        listener = movieListener,
        filename = 'intro_cutscene.ogv'
    }
)

audio.setVolume(1, {channel = player.channel})
player.play()
```

A more advanced usage example can be found in the `Corona/` directory [here](https://github.com/ANSH3LL/plugin_movie/tree/main/Corona)

If you would like to take the DIY option and use a `MovieTexture` to fill an object of your choice, take a look at the implementation of `MovieRect` [here](https://github.com/ANSH3LL/plugin_movie/blob/cfe8c121bc9d797f4ec6622a04f827a10cd56ccd/shared/plugin_movie.lua#L31)

# MovieTexture
A texture object that can play a video

# MovieTexture methods
- `newMovieTexture` - loads a video file and returns a `MovieTexture`
- `movieTexture:play` - starts/resumes video playback
- `movieTexture:pause` - pauses video playback
- `movieTexture:stop` - stops video playback
- `movieTexture:update` - updates audio/video frames (call this once every frame)

# MovieTexture properties
- `movieTexture.isActive` - the status of the video decoder (false when playback is done)
- `movieTexture.isPlaying` - false if playback is paused
- `movieTexture.currentTime` - the current time position of the video in seconds

# MovieRect
A convenient way to load and play videos without worrying about the plugin's inner workings

# MovieRect methods
- `newMovieRect` - returns an `ImageRect` preloaded with a `MovieTexture`
- `MovieRect.play` - starts/resumes video playback
- `MovieRect.pause` - pauses video playback
- `MovieRect.stop` - stops video playback and frees the `MovieRect` object

# MovieRect properties
- `MovieRect.texture` - reference to the `MovieRect`'s `MovieTexture`
- `MovieRect.channel` - the channel used for audio playback (use this to set volume, etc)
- `MovieRect.playing` - false if playback is paused

# MovieLoop
A convenient way to load and play videos in a loop without worrying about the plugin's inner workings

# MovieLoop methods
- `newMovieLoop` - returns a `GroupObject` that automatically plays a video file in a loop using 2 `MovieRect` objects
- `MovieLoop.rect` - returns a handle to the currently playing `MovieRect`
- `MovieLoop.play` - starts/resumes video playback
- `MovieLoop.pause` - pauses video playback
- `MovieLoop.stop` - stops video playback and frees the `MovieLoop` object as well as its associated `MovieRect` objects

# MovieLoop properties
- `MovieLoop.iteration` - the current looping iteration (equal to 1 when no looping has occurred yet)
- `MovieLoop.playing` - false if playback is paused

# Caveats and recommendations
- Only mono and stereo audio is supported. Videos with more than 2 audio channels might not sound as expected
- Playback speed is limited by the engine's fps. It is thus recommended to use videos with a framerate several values below your game's fps as set in `config.lua`
- Depending on video resolution, memory usage could be high
- The `MovieLoop` object consumes around double the memory consumed by the `MovieRect` object
- The `MovieLoop` object might not work very well with really short videos (e.g: videos under 10 seconds long)
- Underpowered devices might experience frame drops, audio stutters and audio/video desynchronization issues
- The plugin is susceptible to all limitations of the theoraplay library. As a result, the only valid pixel format is `TH_PF_420`. This, however, shouldn't be an issue for most use-cases
- It is recommended to remove all other `enterFrame` event listeners before video playback to ensure smooth playback
- It is recommended to wait around half a second after initializing any of the movie objects to allow for buffering of frames

# Simple mp4 to ogv example using ffmpeg
```
ffmpeg -i video.mp4 -c:v libtheora -q:v 7 -c:a libvorbis -q:a 5 -pix_fmt yuv420p video.ogv
```

# Credits
- [theoraplay](https://github.com/icculus/theoraplay) by [@icculus](https://github.com/icculus)
- Insipired by the [theora](https://github.com/ggcrunchy/solar2d-plugins/tree/master/theora) plugin by [@ggcrunchy](https://github.com/ggcrunchy) as well as a video wrapper provided by a user of the [Solar2D discord](https://discord.gg/WMtCemc)
- macOS and iOS builds by [@kwiksher](https://github.com/kwiksher)