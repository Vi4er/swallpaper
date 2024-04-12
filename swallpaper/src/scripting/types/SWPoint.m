#import <scripting/types/SWPoint.h>
#import <scripting/types/Utils.h>

static int __index(lua_State* L) {
    SWPoint point = [lua_toSWPoint(L, 1) SWPointValue];
    NSString* index = [NSString stringWithUTF8String:luaL_checkstring(L, 2)];

    if ([index isEqualToString:@"x"]) {
        lua_pushSWScaled(L, [NSValue valueWithSWScaled:point.x]);
    }
    else if ([index isEqualToString:@"y"]) {
        lua_pushSWScaled(L, [NSValue valueWithSWScaled:point.y]);
    }
    
    return 1;
}

static int __tostring(lua_State* L) {
    SWPoint point = [lua_toSWPoint(L, 1) SWPointValue];
    NSString* str = [NSString stringWithFormat:@"{{%f, %f}, {%f, %f}}", point.x.scale, point.x.offset, point.y.scale, point.y.offset];
    lua_pushstring(L, [str UTF8String]);
    
    return 1;
}

void lua_pushSWPoint(lua_State* L, NSValue* point) {
    SWUserdataInfo info = {
        .name = "Point",
        .__index = __index,
        .__tostring = __tostring
    };

    SWPoint* data = lua_newSWUserdata(L, sizeof(SWPoint), info);
    SWPoint src = [point SWPointValue];
    memcpy(data, &src, sizeof(SWPoint));
}

NSValue* lua_toSWPoint(lua_State* L, int idx) {
    return [NSValue valueWithSWPoint:*(SWPoint*)luaL_checkudata(L, idx, "Point")];
}

static int l_new(lua_State* L) {
    SWPoint point;
    point.x.scale = luaL_checknumber(L, 1);
    point.x.offset = luaL_checknumber(L, 2);
    point.y.scale = luaL_checknumber(L, 3);
    point.y.offset = luaL_checknumber(L, 4);

    lua_pushSWPoint(L, [NSValue valueWithSWPoint:point]);

    return 1;
}

static int l_fromScale(lua_State* L) {
    SWPoint point = {0};
    point.x.scale = luaL_checknumber(L, 1);
    point.y.scale = luaL_checknumber(L, 2);
    lua_pushSWPoint(L, [NSValue valueWithSWPoint:point]);

    return 1;
}

static int l_fromOffset(lua_State* L) {
    SWPoint point = {0};
    point.x.offset = luaL_checknumber(L, 1);
    point.y.offset = luaL_checknumber(L, 2);
    lua_pushSWPoint(L, [NSValue valueWithSWPoint:point]);

    return 1;
}

void lua_registerSWPoint(lua_State* L) {
    luaL_Reg lib[] = {
        { "new", l_new },
        { "fromScale", l_fromScale },
        { "fromOffset", l_fromOffset },
        { NULL, NULL }
    };

    lua_newtable(L);
    luaL_setfuncs(L, lib, 0);
    lua_setglobal(L, "Point");
}
