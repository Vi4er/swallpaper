#pragma once
#import <Foundation/Foundation.h>
#import <scripting/lua.h>

void lua_pushNSString(lua_State* L, NSString* str);
NSString* lua_toNSString(lua_State* L, int idx);
