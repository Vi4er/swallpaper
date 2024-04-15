#pragma once
#import <scripting/lua.h>
#import <elements/SWElement.h>

void lua_pushSWElement(lua_State* L, SWElement* element);
SWElement* lua_toSWElement(lua_State* L, int idx);
void lua_registerSWElement(lua_State* L);
