// ----------------------------------------------------------------------------
// 
// PluginMovie.cpp
// 
// ----------------------------------------------------------------------------

#include "PluginMovie.h"

// ----------------------------------------------------------------------------

CORONA_EXPORT int CoronaPluginLuaLoad_plugin_movie(lua_State *);

// ----------------------------------------------------------------------------

CORONA_EXPORT int luaopen_plugin_movie(lua_State *L) {

    lua_CFunction factory = Corona::Lua::Open<CoronaPluginLuaLoad_plugin_movie>;
    int result = CoronaLibraryNewWithFactory(L, factory, NULL, NULL);

    if(result) {
        const luaL_Reg kFunctions[] = {
            {"_newMovieTexture", newMovieTexture},
            {NULL, NULL}
        };

        luaL_register(L, NULL, kFunctions);
    }

    return result;
}

// ----------------------------------------------------------------------------

struct Movie {
    THEORAPLAY_Decoder *decoder = NULL;
    const THEORAPLAY_VideoFrame *video = NULL;
    const THEORAPLAY_AudioPacket *audio = NULL;

    bool playing = false;
    bool stopped = false;

    bool audiostarted = false;
    bool audiocompleted = false;

    unsigned int elapsed = 0;
    unsigned int framems = 0;

    unsigned char empty[4] = {};

    ALuint source = NULL;
    ALenum audioformat = NULL;
    ALuint buffers[NUM_BUFFERS];
};

// ----------------------------------------------------------------------------

bool startAudioStream(Movie *movie) {
    ALsizei i;

    for(i = 0; i < NUM_BUFFERS; i++) {
        ALsizei size = movie->audio->frames * movie->audio->channels * 2;
        alBufferData(movie->buffers[i], movie->audioformat, movie->audio->samples, size, movie->audio->freq);

        const THEORAPLAY_AudioPacket *next_packet = THEORAPLAY_getAudio(movie->decoder);
        if(!next_packet) break;

        THEORAPLAY_freeAudio(movie->audio);
        movie->audio = next_packet;
    }

    alSourceQueueBuffers(movie->source, i, movie->buffers);
    alSourcePlay(movie->source);

    return true;
}

void stopAudioStream(Movie *movie) {
    alSourceStop(movie->source);
    alSourceRewind(movie->source);

    alSourcei(movie->source, AL_BUFFER, 0);
    alDeleteBuffers(NUM_BUFFERS, movie->buffers);
}

// ----------------------------------------------------------------------------

static unsigned int GetWidth(void *context) {
    Movie *movie = (Movie*)context;
    return movie->video ? movie->video->width : 1;
}

static unsigned int GetHeight(void *context) {
    Movie *movie = (Movie*)context;
    return movie->video ? movie->video->height : 1;
}

static const void* GetImage(void *context) {
    Movie *movie = (Movie*)context;
    return movie->video ? movie->video->pixels : movie->empty;
}

static CoronaExternalBitmapFormat GetFormat(void *context) {
    return kExternalBitmapFormat_RGBA;
}

static int GetField(lua_State *L, const char *field, void *context) {
    int result = 0;

    if(strcmp(field, "update") == 0)
        result = PushCachedFunction(L, update);

    else if(strcmp(field, "play") == 0)
        result = PushCachedFunction(L, play);
    else if(strcmp(field, "pause") == 0)
        result = PushCachedFunction(L, pause);
    else if(strcmp(field, "stop") == 0)
        result = PushCachedFunction(L, stop);

    else if(strcmp(field, "isActive") == 0)
        result = isActive(L, context);
    else if(strcmp(field, "isPlaying") == 0)
        result = isPlaying(L, context);

    else if(strcmp(field, "currentTime") == 0)
        result = currentTime(L, context);

    return result;
}

static void Dispose(void *context) {
    Movie *movie = (Movie*)context;

    if(!movie->stopped) {
        movie->stopped = true;
        movie->playing = false;

        stopAudioStream(movie);
        THEORAPLAY_stopDecode(movie->decoder);
    }

    THEORAPLAY_freeAudio(movie->audio);
    THEORAPLAY_freeVideo(movie->video);

    delete movie;
}

// ----------------------------------------------------------------------------

static int update(lua_State *L) {
    Movie *movie = (Movie*)CoronaExternalGetUserData(L, 1);

    if(movie->playing && THEORAPLAY_isDecoding(movie->decoder)) {
MAINLOOP:
        unsigned int delta = luaL_checkinteger(L, 2);

        if(!movie->audio)
            movie->audio = THEORAPLAY_getAudio(movie->decoder);

        if(!movie->video)
            movie->video = THEORAPLAY_getVideo(movie->decoder);

        if(delta > 0 && (movie->audio || movie->video)) {
            unsigned int currentTime = movie->elapsed + delta;

            if(movie->audio) {
                if(!movie->audioformat)
                    movie->audioformat = (movie->audio->channels == 1) ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;

                if(!movie->audiostarted)
                    movie->audiostarted = startAudioStream(movie);

                ALint state, processed;
                alGetSourcei(movie->source, AL_SOURCE_STATE, &state);
                alGetSourcei(movie->source, AL_BUFFERS_PROCESSED, &processed);

                while(processed > 0) {
                    ALuint buffID;

                    alSourceUnqueueBuffers(movie->source, 1, &buffID);
                    processed--;

                    ALsizei size = movie->audio->frames * movie->audio->channels * 2;
                    alBufferData(buffID, movie->audioformat, movie->audio->samples, size, movie->audio->freq);

                    alSourceQueueBuffers(movie->source, 1, &buffID);

                    const THEORAPLAY_AudioPacket *next_packet = THEORAPLAY_getAudio(movie->decoder);
                    if(!next_packet) break;

                    THEORAPLAY_freeAudio(movie->audio);
                    movie->audio = next_packet;
                }

                if(state != AL_PLAYING && state != AL_PAUSED) {
                    if(THEORAPLAY_availableAudio(movie->decoder))
                        alSourcePlay(movie->source);
                    else
                        movie->audiocompleted = true;
                }
            }

            if(movie->video) {
                if(movie->framems == 0)
                    movie->framems = (unsigned int)(1000.0 / movie->video->fps);

                while(currentTime >= (movie->video->playms + movie->framems)) {
                    const THEORAPLAY_VideoFrame *next_frame = THEORAPLAY_getVideo(movie->decoder);
                    if(!next_frame) break;

                    THEORAPLAY_freeVideo(movie->video);
                    movie->video = next_frame;
                }
            }

            movie->elapsed = currentTime;
        }
    }

    // Finish playing any audio that remains after decoding is completed
    else if(movie->audiostarted && !movie->audiocompleted) {
        goto MAINLOOP;
    }

    return 0;
}

static int play(lua_State *L) {
    Movie *movie = (Movie*)CoronaExternalGetUserData(L, 1);

    if(!movie->playing) {
        movie->playing = true;
        if(movie->audiostarted && !movie->audiocompleted)
            alSourcePlay(movie->source);
    }

    return 0;
}

static int pause(lua_State *L) {
    Movie *movie = (Movie*)CoronaExternalGetUserData(L, 1);

    if(movie->playing) {
        movie->playing = false;
        if(movie->audiostarted && !movie->audiocompleted)
            alSourcePause(movie->source);
    }

    return 0;
}

static int stop(lua_State *L) {
    Movie *movie = (Movie*)CoronaExternalGetUserData(L, 1);

    movie->stopped = true;
    movie->playing = false;
    stopAudioStream(movie);

    THEORAPLAY_stopDecode(movie->decoder);

    return 0;
}

static int isActive(lua_State *L, void *context) {
    Movie *movie = (Movie*)context;

    lua_pushboolean(L, movie->audiostarted && !movie->audiocompleted ? true : THEORAPLAY_isDecoding(movie->decoder));
    return 1;
}

static int isPlaying(lua_State *L, void *context) {
    Movie *movie = (Movie*)context;

    lua_pushboolean(L, movie->playing);
    return 1;
}

static int currentTime(lua_State *L, void *context) {
    Movie *movie = (Movie*)context;

    lua_pushnumber(L, movie->elapsed * 0.001);
    return 1;
}

// ----------------------------------------------------------------------------

static int newMovieTexture(lua_State *L) {
    Movie *movie = new Movie;

    const char *path = lua_tostring(L, 1);

    if(!path) {
        delete movie;

        lua_pushnil(L);
        lua_pushstring(L, "File does not exist");
        return 2;
    }

    movie->decoder = THEORAPLAY_startDecodeFile(path, NUM_MAXFRAMES, THEORAPLAY_VIDFMT_RGBA);

    if(!movie->decoder) {
        delete movie;

        lua_pushnil(L);
        lua_pushstring(L, "Invalid pixel format / insufficient memory");
        return 2;
    }

    movie->source = lua_tonumber(L, 2);

    alSourceRewind(movie->source);
    alSourcei(movie->source, AL_BUFFER, 0);
    alGenBuffers(NUM_BUFFERS, movie->buffers);

    CoronaExternalTextureCallbacks callbacks = {};
    callbacks.size = sizeof(CoronaExternalTextureCallbacks);
    callbacks.getWidth = GetWidth;
    callbacks.getHeight = GetHeight;
    callbacks.onRequestBitmap = GetImage;
    callbacks.getFormat = GetFormat;
    callbacks.onGetField = GetField;
    callbacks.onFinalize = Dispose;

    return CoronaExternalPushTexture(L, &callbacks, movie);
}
