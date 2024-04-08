#pragma once
#import <elements/SWTypes.h>
#import <scripting/lua.h>

typedef struct SWScaledStruct {
    double scale, offset;
} SWScaledStruct;

void lua_pushSWScaled(lua_State* L, SWScaled* scaled);
SWScaled* lua_toSWScaled(lua_State* L, int idx);
void lua_registerSWScaled(lua_State* L);
