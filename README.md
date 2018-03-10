Computer Core
=============

`factorio_computer_core` is a Factorio mod that provides to write programs using the Lua programming language.

This the main part of **computer** mod, is required to use another **coomputer** module

For **modders**, computer adds an interface for you to add your own APIs to the operating system (see below).

Command Line Usage
------------------
The command line simulates a basic shell

These shell commands are internally defined.
Enter `help` to see this list.\
Type `help apis` to see list of available APIs.\
Type `help name` to find out more about the API called "name".

### Some main commands :
- `cat <filename> ...` : concatenate files and return result
- `cd <dirname>` : Moving in the directory tree
- `cp <srcfile> <dstfile>` : copy a file
- `edit <file>` : Edit the file
- `help [apis | apiname]` : Print help
- `label <get|set|clear> [<label>]` : Label is a built in program for computers that will create a label for the computer
- `ls` : List directory contents
- `mkdir <dirname>` : Make directories
- `rm <file>` : remove files or directories
- `run <file>` : Run a script file
- `tree` : list contents of directories in a tree-like format
- `position` : Return the current computer position
- `waypoint` : Edit saved waypoints

### Computer Label
You can add a label for any computer with `label set my_label`.\
Adding a label will create a mount point for this computer and make it available to any other computer.
So you can copy files from one computer to another.

Exemple:
```
-- computer 1
> label set my_computer
> tree
.
├─┬ mnt
│ └── my_computer
└── my_file
> cat my_file
Hello World !


-- computer 2
> tree
.
└─┬ mnt
  └── my_computer
> cp /tmp/mycomputer/my_file copied_file
> tree
.
├─┬ mnt
│ └── my_computer
└── copied_file
> cat copied_file
Hello World !
```



Core APIs
---------
An API (Application Programming Interface) is a collection of code that, rather than being run directly by the user as a program, is meant to be used by other programs (your program).

**Computer** itself ships with a collection of APIs :

- `os API` : The Operating System API allows for interfacing with the Lua based Operating System itself.
Exemple: `os.wait(callback, seconds)` wait a number of seconds before executing callback function.
- `term API` : The Terminal API provides functions for writing text to the terminal. Exemple: `term.write(text)` writes text to the screen

More information available with `help os` and `help term`.

Official *computer* mods
------------------------

- [OnBoard Computer]() : Add a board computer to your cars and write a Lua program to give them an AI


Instructions for modding with *computer core*
---------------------------------------------
### For use **computer** technology has prerequisites :
```
data:extend({
    {
        type = "technology",
        [...]
        prerequisites = {"computer-gauntlet-technology", ...},
        [...]
    },
})
```

### For use remote interface, an example is worth a thousand words:
```
local api = [[
return {
    name = "my_api",
    description = "",
    entities = function(entity)
        -- LuaEntity: entity
        -- If entities function return true, api is available for this entity

        if entity.type ~= "car" then
            return false
        end

        local inventory = entity.grid
        if inventory == nil then
            return false
        else
            inventory = inventory.get_contents()
        end
        if inventory["my_item"] and inventory["my_item"] > 0 then
            -- API is available if entity is a car, and "my_item" is in the car equipment grid
            return true
        end
        return false
    end,
    events = {
        on_script_kill = function(self)
            -- Called when player lua script is kill
            self:stop()
        end
    },
    prototype = {
        __init = {
            "my_api.__init() - Init API",
            function(self)
                -- Called when script player lua script is started
            end
        },

        _privateFunction = {
            "All function with '_' is considered "private" and the player will not be able to access it directly",
            function(self)
            end
        },

        stop = {
            "my_api.stop() - This string will be used if the player uses the help command on this API",
            function(self)
                -- Player can access to "stop" function, and "stop" function can use the private "_privateFunction" function
                self:_privateFunction()
            end
        }
    }
}
]]

for interface_name, interface_functions in pairs(remote.interfaces) do
    if interface_functions["addComputerAPI"] then
        remote.call(interface_name, "addComputerAPI", api)
    end
end
```

Computer load your API from string in this way
```
remote.add_interface("computer_core", {
    addComputerAPI = function(api)
        if type(api) == "string" then
            local construct, err = load(api, nil, "t", {
                ipairs = ipairs,
                pairs = pairs,
                next = next,
                select = select,
                tonumber = tonumber,
                tostring = tostring,
                type = type,
                unpack = unpack,
                table = table,
                string = string,
                math = math,

                defines = defines,

                -- For your dev tests, computer gives you access to a debug function
                debug = function(text)
                    if type(text) == "string" then
                        game.print("Debug: " .. text)
                    elseif type(text) == "table" then
                        game.print("Debug: " .. tostring(text) .. "\n" .. table.tostring(text))
                    else
                        game.print("Debug: " .. tostring(text))
                    end
                end
            })
            assert(err == nil, err)
            local success, obj = pcall(construct)
            assert(success, obj)
            api = obj
        end
        table.insert(computer.apis, api)
    end
})
```

TODO
====
What should be done in the future:
- Networking support
