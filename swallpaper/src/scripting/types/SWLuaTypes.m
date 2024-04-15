#import <scripting/types/SWLuaTypes.h>

void* lua_newSWUserdata(lua_State* L, size_t size, SWUserdataInfo info) {
    void* userdata = lua_newuserdata(L, size);
    luaL_newmetatable(L, info.name);
    
    for (NSString* key in info.metamethods) {
        NSValue* value = [info.metamethods objectForKey:key];
        lua_pushcfunction(L, value.pointerValue);
        lua_setfield(L, -2, [key UTF8String]);
    }

    lua_setmetatable(L, -2);

    return userdata;
}

void lua_registerSWTypes(lua_State* L) {
    lua_registerSWScaled(L);
    lua_registerSWScaled2(L);
    lua_registerSWVector2(L);
    lua_registerSWElement(L);
}
