#!/bin/env lua

local lfs = require('lfs')

local fu = {
  _VERSION     = 'fu v0.1.0',
  _DESCRIPTION = 'A collection of Filesystem Utility functions for Lua.',
  _URL         = 'https://github.com/xpol/lua-fu',
  _LICENSE     = 'MIT'
}

local function findIn(dir, check, files)
  for file in lfs.dir(dir) do
    if file ~= "." and file ~= ".." then
      local f = dir..'/'..file
      if lfs.attributes(f, 'mode') == "directory" then
        findIn(f, check, files)
      elseif check(f) then
        files[#files+1] = f
        print(f)
      end
    end
  end
  return files
end

function fu.find(path, patterns)
  local files = {}
  if type(patterns) == 'string' then
    patterns = {patterns}
  end
  local function check(f)
    for _, p in ipairs(patterns) do
      if f:match(p) then return true end
    end
    return false
  end
  return findIn(path, check, files)
end


function fu.read(filename)
  local f = io.fopen(filename, 'rb')
  local all = f:read('*a')
  f:close()
  return all
end

function fu.write(filename, str)
  local f = io.fopen(filename, 'wb')
  f:write(str)
  f:close()
end

local function basedir(p)
    return p:gsub('[^\\/]+[\\/]?$', '')
end

function fu.mkdirp(p)
  if lfs.attributes(p, 'mode') == 'directory' then
      return nil, 'already exists'
  end

    local b = basedir(p)
    if #b > 0 and lfs.attributes(b, 'mode') ~= 'directory' then
        local r, m = fu.mkdirp(b)
        if not r then return r, m end
    end
    return lfs.mkdir(p)
end


return fu
