#import <scripting/types/SWScaled.h>
#import <scripting/types/Utils.h>

static int __index(lua_State* L) {
    NSString* index = [[NSString alloc] initWithUTF8String:luaL_checkstring(L, 2)];
    NSLog(@"%@\n", index);
    
    return 0;
}

static int __tostring(lua_State* L) {
    SWScaled* scaled = lua_toSWScaled(L, 1);
    NSString* str = [NSString stringWithFormat:@"{%f, %f}", scaled.scale, scaled.offset];
    lua_pushstring(L, [str UTF8String]);
    
    return 1;
}

void lua_pushSWScaled(lua_State* L, SWScaled* scaled) {
    SWUserdataInfo info = {
        .name = "Scaled",
        .__index = __index,
        .__tostring = __tostring
    };

    SWScaledStruct* data = lua_newSWUserdata(L, sizeof(SWScaledStruct), info);
    data->scale = scaled.scale;
    data->offset = scaled.offset;
}

SWScaled* lua_toSWScaled(lua_State* L, int idx) {
    SWScaledStruct* data = luaL_checkudata(L, idx, "Scaled");
    return [SWScaled newWithScale:data->scale offset:data->offset];
}

static int l_new(lua_State* L) {
    SWScaled* scaled = [SWScaled newWithScale:luaL_checknumber(L, 1) offset:luaL_checknumber(L, 2)];
    lua_pushSWScaled(L, scaled);
    return 1;
}

void lua_registerSWScaled(lua_State* L) {
    luaL_Reg lib[] = {
        { "new", l_new },
        { NULL, NULL }
    };

    lua_newtable(L);
    luaL_setfuncs(L, lib, 0);
    lua_setglobal(L, "SWScaled");
}
