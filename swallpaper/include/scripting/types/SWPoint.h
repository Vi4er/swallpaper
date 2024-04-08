#pragma once
#import <elements/SWTypes.h>
#import <scripting/lua.h>
#import <scripting/types/SWScaled.h>

typedef struct SWPointStruct {
    SWScaledStruct x, y;
} SWPointStruct;

void lua_pushSWPoint(lua_State* L, SWPoint* point);
SWPoint* lua_toSWPoint(lua_State* L, int idx);
void lua_registerSWPoint(lua_State* L);
