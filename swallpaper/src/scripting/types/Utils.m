#import <scripting/types/Utils.h>
#import <scripting/types/SWLuaTypes.h>

void* lua_newSWUserdata(lua_State* L, size_t size, SWUserdataInfo info) {
    void* userdata = lua_newuserdata(L, size);
    luaL_newmetatable(L, info.name);

    if (info.__index) {
        lua_pushcfunction(L, info.__index);
        lua_setfield(L, -2, "__index");
    }

    if (info.__newindex) {
        lua_pushcfunction(L, info.__newindex);
        lua_setfield(L, -2, "__newindex");
    }

    if (info.__tostring) {
        lua_pushcfunction(L, info.__tostring);
        lua_setfield(L, -2, "__tostring");
    }

    lua_setmetatable(L, -2);

    return userdata;
}

void lua_registerSWTypes(lua_State* L) {
    lua_registerSWScaled(L);
    lua_registerSWPoint(L);
    lua_registerSWElement(L);
}
