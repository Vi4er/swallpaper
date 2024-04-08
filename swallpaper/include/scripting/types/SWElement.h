#pragma once
#import <elements/SWElement.h>
#import <scripting/lua.h>

void lua_pushSWElement(lua_State* L, SWElement* element);
SWElement* lua_toSWElement(lua_State* L, int idx);
void lua_registerSWElement(lua_State* L);
