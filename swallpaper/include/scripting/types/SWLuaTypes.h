#pragma once
#import <scripting/lua.h>
#import "SWScaled.h"
#import "SWScaled2.h"
#import "SWVector2.h"
#import "SWElement.h"
#import "NSNumber.h"
#import "NSValue.h"
#import "NSString.h"

typedef struct SWUserdataInfo {
    const char* name;
    NSDictionary<NSString*, NSValue*>* metamethods;
} SWUserdataInfo;

void* lua_newSWUserdata(lua_State* L, size_t size, SWUserdataInfo info);
void lua_registerSWTypes(lua_State* L);
