#pragma once
#import <elements/SWEvent.h>
#import <scripting/lua.h>

void lua_pushSWEvent(lua_State* L, SWEvent* event);
SWEvent* lua_toSWEvent(lua_State* L, int idx);
