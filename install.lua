-- ManuOS installer for OpenComputers
-- Usage in-game:
-- wget https://raw.githubusercontent.com/tatarebatshuchu-afk/ManuOS/main/install.lua
-- lua install.lua

local fs = require("filesystem")
local term = require("term")
local component = require("component")
local io = io

local files = {
  ["/init.lua"] = [[
-- ManuOS init.lua
local term = require("term")
term.clear()
term.setCursor(1,1)
print("Welcome to ManuOS!")
print("Type 'help' in the shell for available commands.")
local shell_func, err = loadfile("/bin/sh.lua")
if shell_func then
  local ok, res = pcall(shell_func)
  if not ok then
    print("Error running shell:", res)
  end
else
  print("Failed to load shell:", err)
end
]],

  ["/bin/sh.lua"] = [[
-- Very small interactive shell for ManuOS
local fs = require("filesystem")
local term = require("term")
local io = io

local function list_dir(path)
  if not fs.exists(path) then
    print(path .. ': no such file or directory')
    return
  end
  for file in fs.list(path) do
    io.write(file .. "  ")
  end
  print("")
end

local function run_file(path)
  if not fs.exists(path) then
    print('No such file: ' .. path)
    return
  end
  local f, err = loadfile(path)
  if not f then
    print('Failed to load: ' .. err)
    return
  end
  local ok, res = pcall(f)
  if not ok then
    print('Runtime error:', res)
  end
end

local function print_help()
  print([[ManuOS shell commands:
  help                Show this help
  ls [path]           List directory (default: /)
  run <file>          Run a Lua file
  cat <file>          Print a file
  hello               Run the hello demo
  reboot              Reboot the computer
  exit                Exit the shell (will return to bootloader)
]])
end

print('ManuOS shell. Type help for commands.')
while true do
  io.write('> ')
  local input = io.read()
  if not input then break end
  local args = {}
  for token in input:gmatch("%S+") do table.insert(args, token) end
  local cmd = args[1]
  if not cmd then
    -- nothing
  elseif cmd == 'help' then
    print_help()
  elseif cmd == 'ls' then
    local path = args[2] or '/'
    list_dir(path)
  elseif cmd == 'run' then
    if not args[2] then print('Usage: run <file>') else run_file(args[2]) end
  elseif cmd == 'cat' then
    local path = args[2]
    if not path then print('Usage: cat <file>') else
      if not fs.exists(path) then print('No such file: ' .. path) else
        local f = io.open(path, 'r')
        if f then
          print(f:read('*a'))
          f:close()
        end
      end
    end
  elseif cmd == 'hello' then
    run_file('/usr/bin/hello.lua')
  elseif cmd == 'reboot' then
    local computer = require('computer')
    computer.shutdown(true)
  elseif cmd == 'exit' then
    break
  else
    print('Unknown command: ' .. cmd)
  end
end
]],

  ["/usr/bin/hello.lua"] = [[
-- Demo hello program
print('Hello from ManuOS!')
]],

  ["/etc/os_version"] = "ManuOS 0.1\n",
}

local function make_parents(path)
  local dir = path:match("(.*/)")
  if not dir then return end
  if fs.exists(dir) then return end
  fs.makeDirectory(dir)
end

print('ManuOS installer')
print('This installer will write files to the computer filesystem (e.g. /init.lua).')
print('Press Enter to continue or Ctrl+C to cancel.')
io.read()

local written = 0
for path, content in pairs(files) do
  local ok, err = pcall(function()
    make_parents(path)
    local f = io.open(path, 'w')
    if not f then error('failed to open ' .. path) end
    f:write(content)
    f:close()
  end)
  if ok then
    print('Wrote ' .. path)
    written = written + 1
  else
    print('Failed to write ' .. path .. ': ' .. tostring(err))
  end
end

print(('Installed %d files.'):format(written))
print('Installation complete. To boot ManuOS on next reboot ensure /init.lua is present.')
print('Reboot now? (y/N)')
local ans = io.read()
if ans and (ans:lower() == 'y' or ans:lower() == 'yes') then
  local computer = require('computer')
  computer.shutdown(true)
else
  print('Done. You can reboot the computer to start ManuOS.')
end
