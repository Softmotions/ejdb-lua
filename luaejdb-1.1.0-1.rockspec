package = "luaejdb"
version = "1.1.0-1"
source = {
  url = "https://github.com/Softmotions/ejdb-lua.git"
}
description = {
  summary = "Embedded JSON Database engine Lua binding",
  detailed = [[It aims to be a fast MongoDB-like library which can be embedded into C/C++
  and NodeJS/Python/Lua applications under terms of LGPL license.
   ]],
  homepage = "http://ejdb.org",
  license = "LGPLv2"
}

dependencies = {
  "lua ~> 5.1"
}

external_dependencies = {
   LIBTCEJDB = {
      header = "ejdb/ejdb.h"
   }
}

build = {
  type = "builtin",
  modules = {
    ["ejdb"]  = "ejdb.lua",
    ["ejdb.inspect"]  = "ejdb/inspect.lua",
    ["luaejdb"] = {
       sources = {"luaejdb.c", "luabson.c"},
       libraries = {"ejdb"} ,
       incdirs = {"$(LIBTCEJDB_INCDIR)"},
       libdirs = {"$(LIBTCEJDB_LIBDIR)"},
       defines = {}
    }
  }
}

