#pragma once
#import <scripting/lua.h>
#import <elements/SWTypes.h>

void lua_pushSWScaled(lua_State* L, SWScaled scaled);
SWScaled lua_toSWScaled(lua_State* L, int idx);
void lua_registerSWScaled(lua_State* L);
