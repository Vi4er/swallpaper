#pragma once
#import <scripting/lua.h>

typedef struct SWUserdataInfo {
    const char* name;
    lua_CFunction __index;
    lua_CFunction __newindex;
    lua_CFunction __tostring;
} SWUserdataInfo;

void* lua_newSWUserdata(lua_State* L, size_t size, SWUserdataInfo info);
void lua_registerSWTypes(lua_State* L);
