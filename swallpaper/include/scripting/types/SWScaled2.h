#pragma once
#import <scripting/lua.h>
#import <elements/SWTypes.h>

void lua_pushSWScaled2(lua_State* L, SWScaled2 scaled);
SWScaled2 lua_toSWScaled2(lua_State* L, int idx);
void lua_registerSWScaled2(lua_State* L);
