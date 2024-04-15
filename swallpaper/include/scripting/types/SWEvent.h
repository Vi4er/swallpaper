#pragma once
#import <scripting/lua.h>
#import <elements/SWEvent.h>

void lua_pushSWEvent(lua_State* L, SWEvent* event);
SWEvent* lua_toSWEvent(lua_State* L, int idx);
