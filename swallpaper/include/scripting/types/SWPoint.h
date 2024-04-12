#pragma once
#import <elements/SWTypes.h>
#import <scripting/lua.h>
#import <scripting/types/SWScaled.h>

void lua_pushSWPoint(lua_State* L, NSValue* point);
NSValue* lua_toSWPoint(lua_State* L, int idx);
void lua_registerSWPoint(lua_State* L);
