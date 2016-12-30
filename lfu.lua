#!/bin/env lua

local lfs = require('lfs')

local fu = {
  _VERSION     = 'fu v0.1.0',
  _DESCRIPTION = 'A collection of Filesystem Utility functions for Lua.',
  _URL         = 'https://github.com/xpol/lua-fu',
  _LICENSE     = 'MIT'
}

local function ls(dir, ffn, dfn)
  for file in lfs.dir(dir) do
    if file ~= "." and file ~= ".." then
      local f = dir..'/'..file
      if lfs.attributes(f, 'mode') == "directory" then
        dfn(f, file)
      else
        ffn(f, file)
      end
    end
  end
end

function fu.find(path, patterns)
  local files = {}
  if type(patterns) == 'string' then
    patterns = {patterns}
  end
  local function onfile(f)
    for _, p in ipairs(patterns) do
      if f:match(p) then
        files[#files+1] = f
      end
    end
  end
  local function ondir(dir)
    ls(dir, onfile, ondir)
  end
  ondir(path)
  return files
end

local function walk(dir, deepfirst)
  if lfs.attributes(dir, 'mode') ~= 'directory' then
    return
  end
  local root = dir
  local dirs, files = {}, {}

  ls(root, function(_, f)
    files[#files+1] = f
  end, function(_, d)
    dirs[#dirs+1] = d
  end)
  if not deepfirst then
    coroutine.yield(root, dirs, files)
  end
  for _, d in ipairs(dirs) do
    walk(root..'/'..d, deepfirst)
  end
  if deepfirst then
    coroutine.yield(root, dirs, files)
  end
end


function fu.walk(dir, deepfirst)
  return coroutine.wrap(function() walk(dir, deepfirst) end)
end

local function basedir(p)
    return p:gsub('[^\\/]+[\\/]?$', '')
end

function fu.mkdirp(p)
  if lfs.attributes(p, 'mode') == 'directory' then
    return true
  end
  local b = basedir(p)
  if #b > 0 and lfs.attributes(b, 'mode') ~= 'directory' then
    local r, m = fu.mkdirp(b)
    if not r then return r, m end
  end
  return lfs.mkdir(p)
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


return fu
