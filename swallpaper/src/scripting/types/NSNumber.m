#import <scripting/types/NSNumber.h>

void lua_pushNSNumber(lua_State* L, NSNumber* number) {
    lua_pushnumber(L, [number doubleValue]);
}

NSNumber* lua_toNSNumber(lua_State* L, int idx) {
    return [NSNumber numberWithDouble:lua_tonumber(L, idx)];
}

void lua_pushNSNumberAsBoolean(lua_State* L, NSNumber* number) {
    lua_pushboolean(L, [number intValue]);
}
