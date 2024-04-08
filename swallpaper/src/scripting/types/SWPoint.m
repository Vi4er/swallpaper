#import <scripting/types/SWPoint.h>
#import <scripting/types/Utils.h>

static int __index(lua_State* L) {
    SWPoint* point = lua_toSWPoint(L, 1);
    NSString* index = [[NSString alloc] initWithUTF8String:luaL_checkstring(L, 2)];
    
    if ([index isEqualToString:@"x"]) {
        lua_pushSWScaled(L, point.x);
    }
    else if ([index isEqualToString:@"y"]) {
        lua_pushSWScaled(L, point.y);
    }
    
    return 1;
}

static int __tostring(lua_State* L) {
    SWPoint* point = lua_toSWPoint(L, 1);
    NSString* str = [NSString stringWithFormat:@"{{%f, %f}, {%f, %f}}", point.x.scale, point.x.offset, point.y.scale, point.y.offset];
    lua_pushstring(L, [str UTF8String]);
    
    return 1;
}

void lua_pushSWPoint(lua_State* L, SWPoint* point) {
    SWUserdataInfo info = {
        .name = "Point",
        .__index = __index,
        .__tostring = __tostring
    };
    SWPointStruct* data = lua_newSWUserdata(L, sizeof(SWPointStruct), info);
    
    SWScaledStruct x = { point.x.scale, point.x.offset };
    SWScaledStruct y = { point.y.scale, point.y.offset };
    data->x = x;
    data->y = y;
}

SWPoint* lua_toSWPoint(lua_State* L, int idx) {
    SWPointStruct* data = luaL_checkudata(L, idx, "Point");
    return [SWPoint newWithX:[SWScaled newWithScale:data->x.scale offset:data->x.offset] y:[SWScaled newWithScale:data->y.scale offset:data->y.offset]];
}

static int l_new(lua_State* L) {
    SWPoint* point = [SWPoint newWithX: [SWScaled newWithScale:luaL_checknumber(L, 1) offset:luaL_checknumber(L, 2)] y:[SWScaled newWithScale:luaL_checknumber(L, 3) offset:luaL_checknumber(L, 4)]];
    lua_pushSWPoint(L, point);

    return 1;
}

static int l_fromScale(lua_State* L) {
    SWPoint* point = [SWPoint newWithX: [SWScaled newWithScale:luaL_checknumber(L, 1) offset:0] y:[SWScaled newWithScale:luaL_checknumber(L, 2) offset:0]];
    lua_pushSWPoint(L, point);

    return 1;
}

static int l_fromOffset(lua_State* L) {
    SWPoint* point = [SWPoint newWithX: [SWScaled newWithScale:0 offset:luaL_checknumber(L, 1)] y:[SWScaled newWithScale:0 offset:luaL_checknumber(L, 2)]];
    lua_pushSWPoint(L, point);

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
    lua_setglobal(L, "SWPoint");
}
