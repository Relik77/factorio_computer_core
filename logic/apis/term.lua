require("logic.computer")

table.insert(computer.apis,{
    name = "term",
    description = "The Terminal API provides functions for writing text to the terminal",
    entities = nil,
    events = {
        on_gui_text_changed = function(self, event)
            local gui = event.element
            if not self._listeners then self._listeners = {} end

            for index, item in pairs(self._listeners) do
                if item.event == "on_gui_text_changed" then
                    if not gui.text:startsWith(self.__getOutput()) then
                        return self.__setOutput(self.__getOutput())
                    end

                    local input = gui.text:sub(#self.__getOutput() + 1);

                    local fct, err = load(item.callback, nil, "bt", self.__env)
                    if err then
                        return self.__getAPI('term').write(err)
                    end
                    local success, result = pcall(fct, {
                        listenerID = index,
                        userInput = input
                    })
                    if not success then
                        return self.__getAPI('term').write(result)
                    end
                end
            end
        end,
        after_text_print = function(self, event)
            local gui = event.element
            if not self._listeners then self._listeners = {} end

            for index, item in pairs(self._listeners) do
                if item.event == "after_text_print" then
                    if not gui.text:startsWith(self.__getOutput()) then
                        self.__setOutput(self.__getOutput())
                    end

                    local fct, err = load(item.callback, nil, "bt", self.__env)
                    if err then
                        return self.__getAPI('term').write(err)
                    end
                    local success, result = pcall(fct, {
                        listenerID = index
                    })
                    if not success then
                        return self.__getAPI('term').write(result)
                    end
                end
            end
        end
    },
    prototype = {
        -- Private methods
        __init = {
            "term.__init() - Init API",
            function(self)
                self._listeners = {}
            end
        },

        -- Public methods
        setOutput = {
            "term.setOutput(text) - Writes text to the screen",
            function(self, ...)
                local text = ""
                for index, data in ipairs({...}) do
                    if type(data) == "table" then
                        data = table.tostring(data)
                    end
                    text = text .. data
                end
                self.__setOutput(self.__getOutput() .. text .. "\n")
            end
        },
        getOutput = {
            "term.getOutput() - Read the text to the screen",
            function(self)
                return self.__getOutput()
            end
        },
        setInput = {
            "term.setInput(text) - Writes user input to the end of the screen",
            function(self, text)
                if type(text) == "table" then
                    text = table.tostring(text)
                end
                self.__setInput(text)
            end
        },
        getInput = {
            "term.getInput() - Read user input from the screen",
            function(self, text)
                return self.__getInput()
            end
        },
        read = {
            "term.read() - Read entire text to the screen",
            function(self)
                return self:getOutput() .. self:getInput()
            end
        },
        clear = {
            "term.clear() - Clears the entire screen.",
            function(self)
                self.__setOutput("")
            end
        },
        addOutputListener = {
            "term.addOutputListener(listener) - This method adds a terminal listener: callback is called whenever text is written on the screen. Return the listener ID.",
            function(self, listener)
                table.insert(self._listeners, {
                    event = "after_text_print",
                    callback = string.dump(listener)
                })
                return #self._listeners
            end
        },
        addInputListener = {
            "term.addInputListener(listener) - This method adds a terminal listener: callback is called whenever the user write text on screen. Return the listener ID.",
            function(self, listener)
                table.insert(self._listeners, {
                    event = "on_gui_text_changed",
                    callback = string.dump(listener)
                })
                return #self._listeners
            end
        },
        removeListener = {
            "term.removeListener(listenerID) - This method remove a terminal listener.",
            function(self, listenerID)
                table.remove(self._listeners, listenerID)
            end
        },

        -- Alias
        write = {
            "term.write(text) - Writes text to the screen (Alias: setOutput)",
            function(self, ...)
                return self:setOutput(...)
            end
        }
    }
})
