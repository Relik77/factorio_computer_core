require("logic.computer")

table.insert(computer.apis,{
    name = "wlan",
    description = "The WLAN API provides functions to communicate using wirless network",
    entities = nil,
    events = {
        on_message = function(self, event_name, ...)
            local handlers = self._events[event_name]

            if not handlers then return end
            for index, handler in pairs(handlers) do
                local fct, err = load(handler.callback, nil, "bt", self.__env)
                if err then
                    return self.__getAPI('term').write(err)
                end
                local args = handler.args or {}
                for index, arg in ipairs({...}) do
                    table.insert(args, arg)
                end
                local success, result = pcall(fct, unpack(args))
                if not success then
                    return self.__getAPI('term').write(result)
                end
            end
        end
    },
    prototype = {
        __init = {
            "os.__init() - Init API",
            function(self)
                self._events = {}
            end
        },
        emit = {
            "wlan.emit(label, event_name, ...args) - Emits an event to another computer identified by his label",
            function(self, label, ...)
                self.__emit(label, "on_message", ...)
            end
        },
        broadcast = {
            "wlan.broadcast(event_name, ...args) - Emits an event to all computers",
            function(self, ...)
                self.__broadcast("on_message", ...)
            end
        },
        on = {
            "wlan.on(event_name, callback, ...args) - Register a new handler for the given event",
            function(self, event_name, callback, ...)
                if not self._events[event_name] then
                    self._events[event_name] = {}
                end
                table.insert(self._events[event_name], {
                    callback = string.dump(callback),
                    agrs = {...}
                })
            end
        }
    }
})
