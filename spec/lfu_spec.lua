local lfu  = require('lfu')
local lfs  = require('lfs')

local isWindows
if _G.jit then
  isWindows = _G.jit.os == "Windows"
else
  isWindows = not not package.path:match("\\")
end


local helper = {}
function helper.mkdirs(p)
  if isWindows then
    os.execute('md '..p)
  else
    os.execute('mkdir -p '..p)
  end
end

function helper.rmdirs(p)
  if isWindows then
    os.execute('rd /Q /S '..p)
  else
    os.execute('rm -rf '..p)
  end
end

function helper.mkfile(p)
  local f = io.open(p, 'w')
  f:close()
end


describe('lfu', function()
  local textfiles = {
    't/01.txt',
    't/02.txt',
    't/a/03.txt',
    't/a/04.txt',
    't/a/b/05.txt',
    't/a/b/06.txt',
    't/a/b/c/07.txt',
    't/a/b/c/08.txt',
    't/d/09.txt',
    't/d/10.txt',
    't/d/e/11.txt',
    't/d/e/12.txt',
    't/d/e/f/13.txt',
    't/d/e/f/14.txt',
  }
  setup(function()
    helper.mkdirs('t/a/b/c')
    helper.mkdirs('t/d/e/f')
    for _, v in ipairs(textfiles) do
      helper.mkfile(v)
    end
  end)
  teardown(function()
    helper.rmdirs('t')
  end)
  describe('find()', function()
    it('makes directory if it does not exists', function()
      local found = {}
      for _, f in ipairs(lfu.find('t', '%d')) do
        found[#found+1] = f
      end
      assert.are.same(textfiles, found)
    end)
  end)

  describe('walk()', function()
    local topdown = {
      {'t', {'a', 'd'}, {'01.txt', '02.txt'}},
      {'t/a', {'b'}, {'03.txt', '04.txt'}},
      {'t/a/b', {'c'}, {'05.txt', '06.txt'}},
      {'t/a/b/c', {}, {'07.txt', '08.txt'}},
      {'t/d', {'e'}, {'09.txt', '10.txt'}},
      {'t/d/e', {'f'}, {'11.txt', '12.txt'}},
      {'t/d/e/f', {}, {'13.txt', '14.txt'}},
    }
    local downtop = {
      {'t/a/b/c', {}, {'07.txt', '08.txt'}},
      {'t/a/b', {'c'}, {'05.txt', '06.txt'}},
      {'t/a', {'b'}, {'03.txt', '04.txt'}},
      {'t/d/e/f', {}, {'13.txt', '14.txt'}},
      {'t/d/e', {'f'}, {'11.txt', '12.txt'}},
      {'t/d', {'e'}, {'09.txt', '10.txt'}},
      {'t', {'a', 'd'}, {'01.txt', '02.txt'}},
    }
    it('it walks directory topdown', function()
      local i = 1
      for root, dirs, files in lfu.walk('t') do
        assert.are.same(topdown[i], {root, dirs, files})
        i = i + 1
      end
    end)
    it('it walks directory downtop', function()
      local i = 1
      for root, dirs, files in lfu.walk('t', true) do
        assert.are.same(downtop[i], {root, dirs, files})
        i = i + 1
      end
    end)
    it('it does nothing when directory not exists', function()
      local noop = true
      for _, _, _ in lfu.walk('x', true) do
        noop = false
      end
      assert.is_true(noop)
    end)
  end)

  describe('mkdirp()', function()
    it('makes directory if it does not exists', function()
      assert.is_nil(lfs.attributes('t/c/r/e/a/t/e', 'mode'))
      assert.is_true(lfu.mkdirp('t/c/r/e/a/t/e'))
      assert.are.equal('directory', lfs.attributes('t/c/r/e/a/t/e', 'mode'))
    end)

    it('returns true if directory if already exists', function()
      assert.are.equal('directory', lfs.attributes('t/a/b/c', 'mode'))
      assert.is_true(lfu.mkdirp('t/a/b/c'))
    end)

    it('returns nil plus an error message if failed', function()
      assert.are.equal('file', lfs.attributes('t/01.txt', 'mode'))
      local e, m = lfu.mkdirp('t/01.txt')
      assert.is_nil(e)
      assert.are.equal('File exists', m)
    end)
  end)
end)
