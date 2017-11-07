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
                    item.callback()
                end
            end
        end
    },
    prototype = {
        __init = {
            "os.__init() - Init API",
            function(self)
                self._callbacks = {}
            end
        },
        getComputerID = {
            "os.getComputerID() - Returns the uniq ID of this computer",
            function(self)
                return self.getID()
            end
        },
        getComputerLabel = {
            "os.getComputerLabel() - Returns the label of this computer",
            function(self)
                return self.getLabel()
            end
        },
        setComputerLabel = {
            "os.setComputerLabel(label) - Set the label of this computer",
            function(self, label)
                self.setLabel(label)
            end
        },
        time = {
            "os.time() - Returns the current in-game hour",
            function(self)
                local time = (self.getGameTick() % 25000) / 25000 * 24 + 12
                if time >= 24 then
                    time = time - 24
                end
                return time
            end
        },
        date = {
            "os.date() - Returns the current in-game date",
            function(self)
                return self.getGameTick()
            end
        },
        wait = {
            "os.wait(callback, seconds) - Wait a number of seconds before executing callback function",
            function(self, callback, seconds)
                table.insert(self._callbacks, {
                    type = "wait",
                    time = self.getGameTick() + seconds * 60,
                    callback = callback
                })
            end
        }
    }
})
