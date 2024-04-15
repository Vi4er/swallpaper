#pragma once
#import <scripting/lua.h>
#import <elements/SWTypes.h>

void lua_pushSWVector2(lua_State* L, SWVector2 vector2);
SWVector2 lua_toSWVector2(lua_State* L, int idx);
void lua_registerSWVector2(lua_State* L);
