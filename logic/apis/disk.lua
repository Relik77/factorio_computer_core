require("logic.computer")

table.insert(computer.apis,{
    name = "disk",
    description = "The DISK API provides functions for file manipulation",
    entities = nil,
    prototype = {
    -- Public methods
        readFile = {
            "disk.readFile(filepath) - Returns the contents of the file specified by the argument.",
            function(self, filepath)
                return self.__readFile(filepath)
            end
        },
        writeFile = {
            "disk.writeFile(filepath, ...) - Truncate the file and write the value of each of its arguments.",
            function(self, filepath, ...)
                return self.__writeFile(filepath, ...)
            end
        },
        appendFile = {
            "disk.appendFile(filepath, ...) - Append the value of each of its arguments to the file.",
            function(self, filepath, ...)
                local data = ""
                if self.__fileExist(filepath) then
                    data = self.__readFile(filepath)
                end
                return self.__writeFile(filepath, data, ...)
            end
        },
        removeFile = {
            "disk.removeFile(filepath) - Removes the file specified by the argument if it exists.",
            function(self, filepath)
                if self.__fileExist(filepath) then
                    self.__removeFile(filepath)
                end
            end
        },
        fileExist = {
            "disk.fileExist(filepath) - Return true if given file exist.",
            function(self, filepath)
                return self.__fileExist(filepath)
            end
        },

    -- Alias
    }
})
