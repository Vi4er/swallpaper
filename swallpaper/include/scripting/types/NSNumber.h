#pragma once
#import <Foundation/Foundation.h>
#import <scripting/lua.h>

void lua_pushNSNumber(lua_State* L, NSNumber* number);
void lua_pushNSNumberAsBoolean(lua_State* L, NSNumber* number);
NSNumber* lua_toNSNumber(lua_State* L, int idx);
