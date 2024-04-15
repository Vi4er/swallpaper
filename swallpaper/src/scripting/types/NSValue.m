#import <scripting/types/NSValue.h>
#import <scripting/types/SWLuaTypes.h>

int isType(NSValue* value, char* type) {
    return !strcmp(value.objCType, type);
}

void lua_pushNSValue(lua_State* L, NSValue* value) {
    if (isType(value, @encode(SWScaled2))) {
        lua_pushSWScaled2(L, [value SWScaled2Value]);
    }
    else if (isType(value, @encode(SWScaled))) {
        lua_pushSWScaled(L, [value SWScaledValue]);
    }
    else if (isType(value, @encode(SWVector2))) {
        lua_pushSWVector2(L, [value SWVector2Value]);
    }
}

// TODO: Finish this implementation
NSValue* lua_toNSValue(lua_State* L, int idx) {
    lua_getmetatable(L, idx);
    lua_getfield(L, -1, "__name");
    
    NSString* type = [NSString stringWithUTF8String:lua_tostring(L, -1)];
    lua_pop(L, 1);

    if ([type isEqualToString:@"Scaled"]) {
        return [NSValue valueWithSWScaled:lua_toSWScaled(L, idx)];
    }
    else if ([type isEqualToString:@"Scaled2"]) {
        return [NSValue valueWithSWScaled2:lua_toSWScaled2(L, idx)];
    }
    else if ([type isEqualToString:@"Vector2"]) {
        return [NSValue valueWithSWVector2:lua_toSWVector2(L, idx)];
    }

    return nil;
}
