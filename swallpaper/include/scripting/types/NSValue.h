#pragma once
#import <Foundation/Foundation.h>
#import <scripting/lua.h>

void lua_pushNSValue(lua_State* L, NSValue* value);
NSValue* lua_toNSValue(lua_State* L, int idx);
