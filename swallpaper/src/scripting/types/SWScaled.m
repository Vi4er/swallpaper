#import <scripting/types/SWScaled.h>
#import <scripting/types/SWLuaTypes.h>

static int __index(lua_State* L) {
    SWScaled scaled = lua_toSWScaled(L, 1);
    NSString* index = [NSString stringWithUTF8String:luaL_checkstring(L, 2)];

    if ([index isEqualToString:@"offset"]) {
        lua_pushnumber(L, scaled.offset);
    }
    else if ([index isEqualToString:@"scale"]) {
        lua_pushnumber(L, scaled.scale);
    }
    
    return 1;
}

static int __tostring(lua_State* L) {
    SWScaled scaled = lua_toSWScaled(L, 1);
    NSString* str = [NSString stringWithFormat:@"{%f, %f}", scaled.scale, scaled.offset];
    lua_pushstring(L, [str UTF8String]);
    
    return 1;
}

void lua_pushSWScaled(lua_State* L, SWScaled scaled) {
    SWUserdataInfo info = {
        .name = "Scaled",
        .metamethods = @{
            @"__index": [NSValue valueWithPointer: __index],
            @"__tostring": [NSValue valueWithPointer: __tostring],
        }
    };

    SWScaled* data = lua_newSWUserdata(L, sizeof(SWScaled), info);
    memcpy(data, &scaled, sizeof(SWScaled));
}

SWScaled lua_toSWScaled(lua_State* L, int idx) {
    return *(SWScaled*)luaL_checkudata(L, idx, "Scaled");
}

static int l_new(lua_State* L) {
    SWScaled scaled;
    scaled.scale = luaL_checknumber(L, 1);
    scaled.offset = luaL_checknumber(L, 2);
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
    lua_setglobal(L, "Scaled");
}
