# Movie
A video-to-texture plugin for the solar2D (formerly corona-sdk) game engine

# Usage
Refer to the example project in the `Corona/` directory

# Features
- Plays `Ogg Theora` video files
- Capable of playing videos in a loop
- Renders video to a `CoronaExternalTexture` that can be used to fill a `ShapeObject`, `ImageRect`, etc
- Automatically plays audio in synchronicity with video
- Tiny library (dll / so) file size (less than 500KB)

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
- `MovieRect.channel` - the audio channel used
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
- Only supports windows and android (if you can provide iOS and macOS support, please let me know)
- Only mono and stereo audio is supported. Videos with more than 2 audio channels might not sound as expected
- Playback speed is limited by the engine's fps. It is thus recommended to use videos with a framerate several values below your game's fps as set in `config.lua`
- Depending on video resolution, memory usage could be high
- The `MovieLoop` object consumes around double the memory consumed by the `MovieRect` object
- The `MovieLoop` object might not work very well with really short videos (e.g: videos under 10 seconds long)
- Underpowered devices might experience frame drops, audio stutters and audio/video desynchronization issues
- The plugin is susceptible to all limitations of the theoraplay library. As a result, the only valid pixel format is `TH_PF_420`. This, however, shouldn't be an issue for most use-cases
- If you pause/unpause the video too many times in a row, audio and video might start to go out of sync
- It is recommended to remove all other `enterFrame` event listeners before video playback to ensure smooth playback
- It is recommended to wait around half a second after initializing any of the movie objects to allow for buffering of frames

# Simple mp4 to ogv example using ffmpeg
```
ffmpeg -i video.mp4 -c:v libtheora -q:v 7 -c:a libvorbis -q:a 5 video.ogv
```

# Credits
[theoraplay](https://github.com/icculus/theoraplay) by [@icculus](https://github.com/icculus)
Insipired by the [theora](https://github.com/ggcrunchy/solar2d-plugins/tree/master/theora) plugin by [@ggcrunchy](https://github.com/ggcrunchy) as well as the video wrapper by @BiggestPhish on the [Solar2D discord](https://discord.gg/WMtCemc)