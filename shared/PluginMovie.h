// ----------------------------------------------------------------------------
// 
// PluginMovie.h
// 
// ----------------------------------------------------------------------------

#ifndef _SimulatorPluginLibrary_H__
#define _SimulatorPluginLibrary_H__

#include <cstring>

#include <CoronaLua.h>
#include <CoronaMacros.h>
#include <CoronaLibrary.h>
#include <CoronaGraphics.h>

#include "AL/al.h"
#include "AL/alc.h"
#include "theoraplay.h"

#define NUM_BUFFERS 36
#define NUM_MAXFRAMES 36

// ----------------------------------------------------------------------------

CORONA_EXPORT int luaopen_plugin_movie(lua_State *L);

// ----------------------------------------------------------------------------

static int newMovieTexture(lua_State *L);

// ----------------------------------------------------------------------------

static int PushCachedFunction(lua_State *L, lua_CFunction F) {
    lua_pushlightuserdata(L, (void*)F);
    lua_gettable(L, LUA_REGISTRYINDEX);

    if (!lua_iscfunction(L, -1)) {
        lua_pop(L, 1);
        lua_pushcfunction(L, F);
        lua_pushlightuserdata(L, (void*)F);

        lua_pushvalue(L, -2);
        lua_settable(L, LUA_REGISTRYINDEX);
    }

    return 1;
}

// ----------------------------------------------------------------------------

static int update(lua_State *L);

static int play(lua_State *L);
static int pause(lua_State *L);

static int isActive(lua_State *L, void *context);
static int isPlaying(lua_State *L, void *context);

static int currentTime(lua_State *L, void *context);

// ----------------------------------------------------------------------------

#endif // _SimulatorPluginLibrary_H__
