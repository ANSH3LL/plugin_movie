# Movie
A video-to-texture plugin for the solar2D (formerly corona-sdk) game engine

# Usage
Refer to the example project in the `Corona/` directory

# Features
- Plays `Ogg Theora` video files
- Capable of playing videos in a loop
- Renders video to a `CoronaExternalTexture` that can be used to fill a `ShapeObject`, `ImageRect`, etc
- Automatically plays audio in synchronicity with video

# MovieTexture methods
- `newMovieTexture` - loads a video file and returns a `movieTexture` and the audio `channel` used
- `movieTexture:play` - starts/resumes video playback
- `movieTexture:pause` - pauses video playback
- `movieTexture:update` - updates audio/video frames (call this once every frame)

# MovieTexture properties
- `movieTexture.isActive` - `true` if playback hasn't ended
- `movieTexture.isPlaying` - `false` if playback is paused
- `movieTexture.currentTime` - the current time position of the video in seconds

# MovieRect methods
- `newMovieRect` - provides an ImageRect preloaded with a `movieTexture` for convenience
- `movieRect.play` - starts/resumes video playback
- `movieRect.pause` - pauses video playback
- `movieRect.stop` - stops video playback and frees the `movieRect` resource

# MovieRect properties
- `movieRect.texture` - reference to the `movieRect`'s `movieTexture`
- `movieRect.channel` - the audio `channel` used

# Caveats and recommendations
- Only supports windows and android (if you can provide iOS and macOS support, please let me know)
- Only mono and stereo audio is supported. Videos with more than 2 audio channels might not sound as expected
- Playback speed is limited by the engine's fps. It is thus recommended to use videos with a framerate several values below your game's fps as set in `config.lua`
- It is recommended to remove all other `enterFrame` event listeners before video playback to ensure smooth playback
- Looping and audio *might* be a bit finnicky at times.

# Credits
[theoraplay](https://github.com/icculus/theoraplay) by [@icculus](https://github.com/icculus)
Insipired by the [theora](https://github.com/ggcrunchy/solar2d-plugins/tree/master/theora) plugin by [@ggcrunchy](https://github.com/ggcrunchy)