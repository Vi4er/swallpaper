#import <scripting/types/SWScaled2.h>
#import <scripting/types/SWLuaTypes.h>
#import <scripting/types/SWScaled.h>

static int __index(lua_State* L) {
    SWScaled2 point = lua_toSWScaled2(L, 1);
    NSString* index = [NSString stringWithUTF8String:luaL_checkstring(L, 2)];

    if ([index isEqualToString:@"x"]) {
        lua_pushSWScaled(L, point.x);
    }
    else if ([index isEqualToString:@"y"]) {
        lua_pushSWScaled(L, point.y);
    }
    
    return 1;
}

static int __add(lua_State* L) {
    SWScaled2 a = lua_toSWScaled2(L, 1), b = lua_toSWScaled2(L, 2);
    lua_pushSWScaled2(L, SWMakeScaled2(SWMakeScaled(a.x.scale + b.x.scale, a.x.offset + b.x.offset), SWMakeScaled(a.y.scale + b.y.scale, a.y.offset + b.y.offset)));
    
    return 1;
}

static int __sub(lua_State* L) {
    SWScaled2 a = lua_toSWScaled2(L, 1), b = lua_toSWScaled2(L, 2);
    lua_pushSWScaled2(L, SWMakeScaled2(SWMakeScaled(a.x.scale - b.x.scale, a.x.offset - b.x.offset), SWMakeScaled(a.y.scale - b.y.scale, a.y.offset - b.y.offset)));
    
    return 1;
}

static int __mul(lua_State* L) {
    SWScaled2 a = lua_toSWScaled2(L, 1);

    if (lua_type(L, 2) == LUA_TUSERDATA) {
        SWScaled2 b = lua_toSWScaled2(L, 2);
        lua_pushSWScaled2(L, SWMakeScaled2(SWMakeScaled(a.x.scale * b.x.scale, a.x.offset * b.x.offset), SWMakeScaled(a.y.scale * b.y.scale, a.y.offset * b.y.offset)));
    }
    else {
        double b = luaL_checknumber(L, 2);
        lua_pushSWScaled2(L, SWMakeScaled2(SWMakeScaled(a.x.scale * b, a.x.offset * b), SWMakeScaled(a.y.scale * b, a.y.offset * b)));
    }

    return 1;
}

static int __div(lua_State* L) {
    SWScaled2 a = lua_toSWScaled2(L, 1);
    
    if (lua_type(L, 2) == LUA_TUSERDATA) {
        SWScaled2 b = lua_toSWScaled2(L, 2);
        lua_pushSWScaled2(L, SWMakeScaled2(SWMakeScaled(a.x.scale / b.x.scale, a.x.offset / b.x.offset), SWMakeScaled(a.y.scale / b.y.scale, a.y.offset / b.y.offset)));
    }
    else {
        double b = luaL_checknumber(L, 2);
        lua_pushSWScaled2(L, SWMakeScaled2(SWMakeScaled(a.x.scale / b, a.x.offset / b), SWMakeScaled(a.y.scale / b, a.y.offset / b)));
    }
    
    return 1;
}

static int __tostring(lua_State* L) {
    SWScaled2 point = lua_toSWScaled2(L, 1);
    NSString* str = [NSString stringWithFormat:@"{{%f, %f}, {%f, %f}}", point.x.scale, point.x.offset, point.y.scale, point.y.offset];
    lua_pushstring(L, [str UTF8String]);
    
    return 1;
}

void lua_pushSWScaled2(lua_State* L, SWScaled2 scaled2) {
    SWUserdataInfo info = {
        .name = "Scaled2",
        .metamethods = @{
            @"__index": [NSValue valueWithPointer: __index],
            @"__tostring": [NSValue valueWithPointer: __tostring],
            @"__add": [NSValue valueWithPointer: __add],
            @"__sub": [NSValue valueWithPointer: __sub],
            @"__mul": [NSValue valueWithPointer: __mul],
            @"__div": [NSValue valueWithPointer: __div]
        }
    };

    SWScaled2* data = lua_newSWUserdata(L, sizeof(SWScaled2), info);
    memcpy(data, &scaled2, sizeof(SWScaled2));
}

SWScaled2 lua_toSWScaled2(lua_State* L, int idx) {
    return *(SWScaled2*)luaL_checkudata(L, idx, "Scaled2");
}

static int l_new(lua_State* L) {
    SWScaled2 point;
    point.x.scale = luaL_checknumber(L, 1);
    point.x.offset = luaL_checknumber(L, 2);
    point.y.scale = luaL_checknumber(L, 3);
    point.y.offset = luaL_checknumber(L, 4);

    lua_pushSWScaled2(L, point);

    return 1;
}

static int l_fromScale(lua_State* L) {
    SWScaled2 point = {0};
    point.x.scale = luaL_checknumber(L, 1);
    point.y.scale = luaL_checknumber(L, 2);
    lua_pushSWScaled2(L, point);

    return 1;
}

static int l_fromOffset(lua_State* L) {
    SWScaled2 point = {0};
    point.x.offset = luaL_checknumber(L, 1);
    point.y.offset = luaL_checknumber(L, 2);
    lua_pushSWScaled2(L, point);

    return 1;
}

void lua_registerSWScaled2(lua_State* L) {
    luaL_Reg lib[] = {
        { "new", l_new },
        { "fromScale", l_fromScale },
        { "fromOffset", l_fromOffset },
        { NULL, NULL }
    };

    lua_newtable(L);
    luaL_setfuncs(L, lib, 0);
    lua_setglobal(L, "Scaled2");
}
