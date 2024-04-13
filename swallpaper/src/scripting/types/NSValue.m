#import <scripting/types/NSValue.h>
#import <scripting/types/SWLuaTypes.h>

int isType(NSValue* value, char* type) {
    return !strcmp(value.objCType, type);
}

void lua_pushNSValue(lua_State* L, NSValue* value) {
    if (isType(value, @encode(SWPoint))) {
        lua_pushSWPoint(L, [value SWPointValue]);
    }
}

// TODO: Finish this implementation
NSValue* lua_toNSValue(lua_State* L, int idx) {
    void* userdata = lua_touserdata(L, idx);
    lua_getmetatable(L, idx);
    lua_getfield(L, -1, "__name");
    
    const char* type = lua_tostring(L, -1);
    NSLog(@"%s\n", type);
    
    if (!strcmp(type, "Point")) {
        lua_pop(L, 1);
        return [NSValue valueWithSWPoint:lua_toSWPoint(L, idx)];
    }

    return nil;
}
