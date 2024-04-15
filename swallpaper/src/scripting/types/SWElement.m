#import <scripting/types/SWElement.h>
#import <scripting/types/SWLuaTypes.h>
#import <scripting/SWEnumParser.h>

static int l_new(lua_State* L) {
    lua_pushSWElement(L, [SWElement new]);
    return 1;
}

static int l_getElementById(lua_State* L) {
    NSString* elementId = [NSString stringWithUTF8String:luaL_checkstring(L, 1)];
    lua_pushSWElement(L, [SWElement getElementById:elementId]);
    return 1;
}

static int l_addEventListener(lua_State* L) {
    if (lua_type(L, -1) != LUA_TFUNCTION) {
        luaL_error(L, "addEventListener expects a function, got %s", lua_typename(L, lua_type(L, 3)));
    }
    
    SWElement* element = lua_toSWElement(L, 1);
    NSString* eventName = [NSString stringWithUTF8String:luaL_checkstring(L, 2)];
    SWEventType eventType = [SWEnumParser parseSWEvent:eventName];
    
    if (eventType == kSWEventTypeInvalid) {
        NSLog(@"Invalid event name '%@'\n", eventName);
        return 0;
    }
    
    int ref = luaL_ref(L, LUA_REGISTRYINDEX);
    [element addEventListener:eventType ref:ref];
    lua_pushinteger(L, ref);
    
    return 1;
}

static int l_removeEventListener(lua_State* L) {
    SWElement* element = lua_toSWElement(L, 1);
    NSString* eventName = [NSString stringWithUTF8String:luaL_checkstring(L, 2)];
    SWEventType eventType = [SWEnumParser parseSWEvent:eventName];
    
    if (eventType == kSWEventTypeInvalid) {
        NSLog(@"Invalid event name '%@'\n", eventName);
        return 0;
    }
    
    [element removeEventListener:eventType ref:(int)luaL_checkinteger(L, 3)];
    
    return 0;
}

static int __index(lua_State* L) {
    SWElement* element = lua_toSWElement(L, 1);
    NSString* index = [NSString stringWithUTF8String:luaL_checkstring(L, 2)];
    
    if ([index isEqualToString:@"addEventListener"]) {
        lua_pushcfunction(L, l_addEventListener);
    }
    else if ([index isEqual:@"children"]) {
        lua_newtable(L);
        
        for (int i = 0; i < element.children.count; ++i) {
            lua_pushSWElement(L, element.children[i]);
            lua_rawseti(L, -2, i + 1);
        }
    }
    else {
        SWPropertyDefinition* property = [[[element class] properties] getPropertyDefinition:index];
        
        if (property) {
            SWPropertyTypeDefinition* type = [SWPropertyTypeDefinition typeDefinitions][property.type];
            type.luaPush(L, property.get(element));
        }
    }

    return 1;
}

static int __newindex(lua_State* L) {
    SWElement* element = lua_toSWElement(L, 1);
    NSString* index = [NSString stringWithUTF8String:luaL_checkstring(L, 2)];

    SWPropertyDefinition* property = [[[element class] properties] getPropertyDefinition:index];
    
    if (property) {
        SWPropertyTypeDefinition* type = [SWPropertyTypeDefinition typeDefinitions][property.type];
        property.set(element, type.luaTo(L, 3));
    }
    
    return 0;
}

SWElement* lua_toSWElement(lua_State* L, int idx) {
    return (__bridge SWElement*)*(void**)luaL_checkudata(L, idx, "Element");
}

void lua_pushSWElement(lua_State* L, SWElement* element) {
    if (element) {
        SWUserdataInfo info = {
            .name = "Element",
            .metamethods = @{
                @"__index": [NSValue valueWithPointer: __index],
                @"__newindex": [NSValue valueWithPointer: __newindex],
            }
        };

        void** data = lua_newSWUserdata(L, sizeof(void*), info);
        *data = (__bridge void*)element;
    }
    else {
        lua_pushnil(L);
    }
}

void lua_registerSWElement(lua_State* L) {
    luaL_Reg lib[] = {
        { "new", l_new },
        { "getById", l_getElementById },
        { NULL, NULL }
    };

    lua_newtable(L);
    luaL_setfuncs(L, lib, 0);
    lua_setglobal(L, "Element");
}
