#import <scripting/types/NSString.h>

void lua_pushNSString(lua_State* L, NSString* str) {
    lua_pushstring(L, [str UTF8String]);
}

NSString* lua_toNSString(lua_State* L, int idx) {
    return [NSString stringWithUTF8String:lua_tostring(L, idx)];
}
