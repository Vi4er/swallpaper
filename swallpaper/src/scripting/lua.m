#import <scripting/lua.h>
#import <scripting/types/Utils.h>

lua_State* SWLuaState;

void SWInitLua(void) {
    SWLuaState = luaL_newstate();
    luaL_openlibs(SWLuaState);
    lua_registerSWTypes(SWLuaState);
}
