function compile_remove(f)
  node.compile(f)
  file.remove(f)
end

local files = {
  'config.lua',
  'wifi.lua',
  'server.lua',
  'elog.lua'
}

local filelist = file.list()

for i,f in ipairs(files) do
  if (filelist[f]) then
    print('compiling ' .. f)
    compile_remove(f)
  end
end

dofile('config.lc')
dofile('wifi.lc')
dofile('server.lc')