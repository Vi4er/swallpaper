#pragma once
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

extern lua_State* SWLuaState;
void SWInitLua(void);
