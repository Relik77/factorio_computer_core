require("logic.computer")

table.insert(computer.apis,{
    name = "os",
    description = "The Operating System API allows for interfacing with the Lua based Operating System itself.",
    entities = nil,
    events = {
        on_tick = function(self, event)
            if not self._callbacks then self._callbacks = {} end

            for index, item in pairs(self._callbacks) do
                if item.type == "wait" and event.tick >= item.time then
                    self._callbacks[index] = nil
                    local fct, err = load(item.callback, nil, "bt", self.__env)
                    if err then
                        return self.__getAPI('term').write(err)
                    end
                    local success, result = pcall(fct, unpack(item.args or {}))
                    if not success then
                        return self.__getAPI('term').write(result)
                    end
                end
            end
        end
    },
    prototype = {
        __init = {
            "os.__init() - Init API",
            function(self)
                self._callbacks = {}
                self._data = {}
            end
        },
        getComputerID = {
            "os.getComputerID() - Returns the uniq ID of this computer",
            function(self)
                return self.__getID()
            end
        },
        getComputerLabel = {
            "os.getComputerLabel() - Returns the label of this computer",
            function(self)
                return self.__getLabel()
            end
        },
        setComputerLabel = {
            "os.setComputerLabel(label) - Set the label of this computer",
            function(self, label)
                self.__setLabel(label)
            end
        },
        time = {
            "os.time() - Returns the current in-game hour",
            function(self)
                local time = (self.__getGameTick() % 25000) / 25000 * 24 + 12
                if time >= 24 then
                    time = time - 24
                end
                return time
            end
        },
        date = {
            "os.date() - Returns the current in-game date",
            function(self)
                return self.__getGameTick()
            end
        },
        set = {
            "os.set(name, ...args) - Sets environment variables for the given name",
            function(self, name, ...)
                self._data[name] = {...}
            end
        },
        get = {
            "os.get(name) - Returns environment variables of the given name",
            function(self, name)
                return unpack(self._data[name] or {})
            end
        },
        clear = {
            "os.clear(name) - Remove environment variables for the given name",
            function(self, name)
                self._data[name] = nil
            end
        },
        pcall = {
            "os.pcall(callback, ...) - The os.pcall function calls its first argument in protected mode, so that it catches any errors while the function is running. If there are no errors, pcall returns true, plus any values returned by the call. Otherwise, it returns false, plus the error message.",
            function(self, callback, ...)
                local fct, err = load(string.dump(callback), nil, "b", self.__env)
                if err then
                    return false, err
                end
                return pcall(fct, ...)
            end
        },
        wait = {
            "os.wait(callback, seconds, ...args) - Wait a number of seconds before executing callback function",
            function(self, callback, seconds, ...)
                table.insert(self._callbacks, {
                    type = "wait",
                    time = self.__getGameTick() + seconds * 60,
                    callback = string.dump(callback),
                    args = {...}
                })
            end
        },
        require = {
            "os.require(filepath) - load and run library file",
            function(self, filepath)
                assert(type(filepath) == "string", "'os.require' require a filepath")
                assert(filepath ~= ".", "Unable to require directory '.'")
                assert(filepath ~= "..", "Unable to require directory '..'")

                return self.__require(filepath)
            end
        }
    }
})
