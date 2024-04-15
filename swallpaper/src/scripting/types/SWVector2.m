#import <scripting/types/SWVector2.h>
#import <scripting/types/SWLuaTypes.h>

static int __index(lua_State* L) {
    SWVector2 vector2 = lua_toSWVector2(L, 1);
    NSString* index = [NSString stringWithUTF8String:luaL_checkstring(L, 2)];

    if ([index isEqualToString:@"x"]) {
        lua_pushnumber(L, vector2.x);
    }
    else if ([index isEqualToString:@"y"]) {
        lua_pushnumber(L, vector2.y);
    }
    
    return 1;
}

static int __tostring(lua_State* L) {
    SWVector2 vector2 = lua_toSWVector2(L, 1);
    NSString* str = [NSString stringWithFormat:@"{%f, %f}", vector2.x, vector2.y];
    lua_pushstring(L, [str UTF8String]);
    
    return 1;
}

void lua_pushSWVector2(lua_State* L, SWVector2 vector2) {
    SWUserdataInfo info = {
        .name = "Vector2",
        .metamethods = @{
            @"__index": [NSValue valueWithPointer: __index],
            @"__tostring": [NSValue valueWithPointer: __tostring],
        }
    };

    SWVector2* data = lua_newSWUserdata(L, sizeof(SWVector2), info);
    memcpy(data, &vector2, sizeof(SWVector2));
}

SWVector2 lua_toSWVector2(lua_State* L, int idx) {
    return *(SWVector2*)luaL_checkudata(L, idx, "Vector2");
}

static int l_new(lua_State* L) {
    SWVector2 vector2;
    vector2.x = luaL_checknumber(L, 1);
    vector2.y = luaL_checknumber(L, 2);
    lua_pushSWVector2(L, vector2);
    return 1;
}

void lua_registerSWVector2(lua_State* L) {
    luaL_Reg lib[] = {
        { "new", l_new },
        { NULL, NULL }
    };

    lua_newtable(L);
    luaL_setfuncs(L, lib, 0);
    lua_setglobal(L, "Vector2");
}
