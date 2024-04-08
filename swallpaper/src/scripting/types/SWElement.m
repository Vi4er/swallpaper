#import <scripting/types/SWElement.h>
#import <scripting/types/Utils.h>

static int __index(lua_State* L) {
    SWElement* element = (__bridge SWElement*)*(void**)luaL_checkudata(L, 1, "Element");
    NSString* index = [[NSString alloc] initWithUTF8String:luaL_checkstring(L, 2)];
    
    SWPropertyDefinition* property = [[[element class] properties] getPropertyDefinition:index];
    
    if (property) {
        SWPropertyTypeDefinition* type = [SWPropertyTypeDefinition typeDefinitions][property.type];
        type.luaPush(L, property.get(element));
    }
    
    return 1;
}

void lua_pushSWElement(lua_State* L, SWElement* element) {
    SWUserdataInfo info = {
        .name = "Element",
        .__index = __index
    };

    void** data = lua_newSWUserdata(L, sizeof(void*), info);
    *data = (__bridge void*)element;
}

void lua_registerSWElement(lua_State* L) {
    
}
