#import <scripting/types/SWEvent.h>
#import <scripting/types/Utils.h>
#import <Foundation/Foundation.h>

static int __index(lua_State* L) {
    SWEvent* event = lua_toSWEvent(L, 1);
    NSString* index = [NSString stringWithUTF8String:luaL_checkstring(L, 2)];
    
    if ([index isEqualToString:@"type"]) {
        lua_pushnumber(L, event.type);
    }

    return 1;
}

SWEvent* lua_toSWEvent(lua_State* L, int idx) {
    return (__bridge SWEvent*)*(void**)luaL_checkudata(L, idx, "Event");
}

void lua_pushSWEvent(lua_State* L, SWEvent* event) {
    SWUserdataInfo info = {
        .name = "Event",
        .__index = __index
    };

    void** data = lua_newSWUserdata(L, sizeof(void*), info);
    *data = (__bridge void*)event;
}
