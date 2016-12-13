package = "lfu"
version = "0.1.0-1"
local v = version:gsub("%-%d", "")
source = {
  url = "git://github.com/xpol/lua-fu",
  tag="v"..v
}
description={
   summary = "A collection of Filesystem Utility functions for Lua.",
   detailed = [[A collection of Filesystem Utility functions for Lua.
* find
* mkdirp
* read
* write
]],
   homepage = "https://github.com/xpol/lua-fu",
   license = "MIT"
}
dependencies = {
  "lua >= 5.1",
  "luafilesystem >= 1.5.0"
}

build = {
	type="builtin",
	modules={
		lfu="lfu.lua"
	}
}
