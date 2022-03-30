This documents the various options available when using the various objects provided by the movie plugin

-- returns a texture object
movie.newMovieTexture{
    filename = string, -- the video's filename [required]
    baseDir = userdata, -- file's base directory, e.g: system.ResourceDirectory [optional]
    channel = number -- audio channel to use [optional]
}

-- returns an imagerect
movie.newMovieRect{
    x = number, -- [required]
    y = number, -- [required]

    width = number, -- [required]
    height = number, -- [required]

    filename = string, -- the video's filename [required]
    baseDir = userdata, -- file's base directory, e.g: system.ResourceDirectory [optional]
    channel = number, -- audio channel to use [optional]
    listener = function -- callback function that will receive events from this object [optional]
}

-- returns a group with 2 imagerect objects named one and two
-- channel1 and channel2 MUST be different (especially if the video contains audio)
movie.newMovieLoop{
    x = number, -- [required]
    y = number, -- [required]

    width = number, -- [required]
    height = number, -- [required]

    channel1 = number, -- audio channel used by imagerect one [required]
    channel2 = number, -- audio channel used by imagerect two [required]

    filename = string, -- the video's filename [required]
    baseDir = userdata, -- file's base directory, e.g: system.ResourceDirectory [optional]
    listener = function -- callback function that will receive events from this object [optional]
}
