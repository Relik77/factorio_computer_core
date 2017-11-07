require("logic.computer")

table.insert(computer.apis,{
    name = "term",
    description = "The Terminal API provides functions for writing text to the terminal",
    entities = nil,
    prototype = {
        write = {
            "term.write(text) - Writes text to the screen",
            function(self, text)
                if type(text) == "table" then
                    text = table.tostring(text)
                end
                self.setOutput(self.getOutput() .. text .. "\n")
            end
        },
        clear = {
            "term.clear() - Clears the entire screen.",
            function(self)
                self.setOutput("")
            end
        }
    }
})
