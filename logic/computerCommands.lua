require("logic.computer")

local function apiAllowed(api, entity)
    if type(api.entities) == "function" then
        local success, result = pcall(api.entities, entity)
        if success then
            return result
        end
    elseif type(api.entities) == "table" then
        return table.contains(api.entities, entity.name)
    else
        if type(api.entities) == "string" then
            local fct, err = load(api.entities, nil, "t", baseEnv)
            assert(err == nil, err)
            local success, test = pcall(fct)
            assert(success, test)
            local success, result = pcall(test, entity)
            if success then
                return result
            else
                return false
            end
        end
        return true
    end
end

computer.commands = {
    cat = {
        "cat <filename> ... - concatenate files and return result",
        function(self, fs, ...)
            local text = ""
            local file = fs.cwd

            if #{...} == 0 then
                return computer.commands.cat[1]
            end
            for i, filename in ipairs({...}) do
                if type(filename) == "string" then
                    if filename == "." then
                        return "Unable to cat directory '.'", false
                    elseif filename == ".." then
                        return "Unable to cat directory '..'", false
                    elseif fs.cwd == fs.root and filename == "mnt" then
                        return "Unable to cat virtual directory 'mnt'"
                    else
                        if filename:startsWith("/") then
                            file = fs.root
                        end

                        for index, _dirname in pairs(filename:split("/")) do
                            if _dirname ~= "" then
                                if file.type ~= "dir" then
                                    return filename .. " isn't a directory", false
                                end
                                if file.files[_dirname] ~= nil then
                                    file = file.files[_dirname]
                                else
                                    if file == fs.root and _dirname == "mnt" then
                                        file = {
                                            type = "dir",
                                            files = {}
                                        }
                                        for label, _computer in pairs(self:getLabeleld()) do
                                            file.files[label] = _computer.data.root
                                        end
                                    else
                                        return filename .. " no such file or directory", false
                                    end
                                end
                            end
                        end
                        if file.type ~= "file" then
                            return filename .. " isn't a file", false
                        end
                    end
                    text = text .. file.text
                end
            end
            return text, true
        end
    },
    cd = {
        "cd <dirname> - Moving in the directory tree",
        function(self, fs, dirname)
            local folder = fs.cwd

            if not dirname then
                return computer.commands.cd[1]
            end
            if dirname == "." then
            elseif dirname == ".." then
                fs.cwd = fs.cwd.parent
            elseif dirname:startsWith("/") then
                local cwd = fs.cwd
                fs.cwd = fs.root

                for index, _dirname in pairs(dirname:split("/")) do
                    if _dirname ~= "" then
                        if fs.cwd.files[_dirname] ~= nil then
                            if fs.cwd.files[_dirname].type == "dir" then
                                fs.cwd = fs.cwd.files[_dirname]
                            else
                                fs.cwd = cwd
                                return dirname .. " isn't a directory"
                            end
                        else
                            fs.cwd = cwd
                            return dirname .. " no such file or directory"
                        end
                    end
                end
            else
                if dirname:startsWith("/") then
                    folder = fs.root
                end

                for index, _dirname in pairs(dirname:split("/")) do
                    if _dirname ~= "" then
                        if folder.files[_dirname] ~= nil then
                            if folder.files[_dirname].type == "dir" then
                                folder = folder.files[_dirname]
                            else
                                return dirname .. " isn't a directory"
                            end
                        else
                            return dirname .. " no such file or directory"
                        end
                    end
                end

                fs.cwd = folder
            end
        end
    },
    clear = {
        "clear - Clear computer history",
        function(self)
            self.history = self:exec("pwd") .. "> "
        end
    },
    cp = {
        "cp <srcfile> <dstfile> - copy a file",
        function(self, fs, srcfile, dstfile)
            if not srcfile or not dstfile then
                return computer.commands.cp[1]
            end
            local content, success = self:exec("cat " .. srcfile)

            if not success then
                return content
            end

            local file = self:exec("touch " .. dstfile)
            if type(file) == "string" then
                return file
            end

            file.text = content
        end
    },
    date = {
        "date - Return the current in-game date",
        function(self)
            return toDate(game.tick)
        end
    },
    edit = {
        "edit <file> - Edit the file",
        function(self, fs, filename)
            local file = fs.cwd

            if not filename then
                return computer.commands.edit[1]
            end
            if type(filename) == "string" then
                if filename == "." then
                    return "Unable to edit directory '.'"
                elseif filename == ".." then
                    return "Unable to edit directory '..'"
                elseif fs.cwd == fs.root and filename == "mnt" then
                    return "Unable to edit virtual directory 'mnt'"
                else
                    if filename:startsWith("/") then
                        file = fs.root
                    end

                    local path, count = filename:split("/")
                    for index, _dirname in pairs(path) do
                        count = count - 1

                        if _dirname ~= "" then
                            if file.type ~= "dir" then
                                return filename .. " isn't a directory"
                            end
                            if file.files[_dirname] ~= nil then
                                file = file.files[_dirname]
                            elseif count == 0 then
                                local parent = file
                                file = {
                                    type = "file",

                                    parent = parent,
                                    name = _dirname,

                                    ctime = game.tick,
                                    mtime = game.tick,
                                    atime = game.tick,

                                    text = ""
                                }
                                parent.files[_dirname] = file
                            else
                                return filename .. " no such file or directory"
                            end
                        end
                    end
                    if file.type ~= "file" then
                        return filename .. " isn't a file"
                    end
                end
            else
                file = filename
            end

            file.atime = game.tick;
            self:openGui("editor"):loadFile(file)
        end
    },
    exit = {
        "exit - Close computer",
        function(self)
            self:closeGui()
        end
    },
    help = {
        "help [apis | apiname] - Print help",
        function(self, fs, arg)
            local text = ""

            if not arg then
                for index, value in pairs(computer.commands) do
                    text = text .. value[1] .. "\n"
                end
            elseif arg == "apis" then
                text = text .. "Available APIs:\n"
                for name, api in pairs(baseEnv) do
                    if type(api) == "table" then
                        if name ~= "defines" then
                            text = text .. name .. " - " .. name .. " is a default Lua API\n"
                        else
                            text = text .. "defines - defines is a Factorio default table\n"
                        end
                    end
                end
                for index, api in pairs(computer.apis) do
                    if apiAllowed(api, fs.entity) then
                        text = text .. api.name .. " - " .. api.description .. "\n"
                    end
                end
            elseif type(baseEnv[arg]) == "table" then
                for name, fct in pairs(baseEnv[arg]) do
                    text = text .. arg .. "." .. name .. "\n"
                end
            else
                for i, api in pairs(computer.apis) do
                    if api.name == arg and apiAllowed(api, fs.entity) then
                        for index, value in pairs(api.prototype or {}) do
                            if not index:startsWith("_") then
                                text = text .. value[1] .. "\n"
                            end
                        end
                    end
                end
                if text == "" then
                    text = "No such api '" .. arg .. "' available for this device\n"
                end
            end

            return text
        end
    },
    id = {
        "id - Returns the uniq ID of this computer",
        function(self, fs)
            return table.id(fs)
        end
    },
    label = {
        "label <get|set|clear> [<label>] - Label is a built in program for computers that will create a label for the computer",
        function(self, fs, method, label)
            if not method or method == "get" then
                return fs.label
            elseif method == "set" then
                if not label then
                    return computer.commands.label[1]
                end
                fs.label = label
            elseif method == "clear" then
                fs.label = nil
            end
        end
    },
    ls = {
        "ls - List directory contents",
        function(self, fs, dirname)
            local folder = fs.cwd
            local file
            local text = ""

            if dirname then
                if dirname == "." then
                elseif dirname == ".." then
                    folder = folder.parent
                elseif fs.cwd == fs.root and dirname == "mnt" then
                    local labels = self:getLabeleld()
                    for label, v in pairs(labels) do
                        text = text .. "- " .. " " .. label .. "\n"
                    end
                    return text
                else
                    if dirname:startsWith("/") then
                        folder = fs.root
                    end
                    local parts = dirname:split("/")
                    local count = table.len(parts)
                    for index, _dirname in pairs(parts) do
                        count = count - 1
                        if _dirname ~= "" then
                            if folder.files[_dirname] ~= nil then
                                folder = folder.files[_dirname]
                            else
                                if folder == fs.root and _dirname == "mnt" then
                                    if count == 0 then
                                        local labels = self:getLabeleld()
                                        for label, v in pairs(labels) do
                                            text = text .. "- " .. " " .. label .. "\n"
                                        end
                                        return text
                                    else
                                        return "Unable to list contents of a remote folder"
                                    end
                                end
                                return dirname .. " no such file or directory"
                            end
                        end
                    end
                    if folder.type ~= "dir" then
                        return dirname .. " isn't a directory"
                    end
                end
            end

            text = text .. "d " .. toDate(folder.mtime):padRight(12) .. " .\n"
            text = text .. "d " .. toDate(folder.parent.mtime):padRight(12) .. " ..\n"

            if folder == fs.root then
                text = text .. "d " .. toDate(folder.mtime):padRight(12) .. " mnt\n"
            end

            for filename, fd in pairs(folder.files) do
                file = folder.files[filename]
                if file.type == "file" then
                    text = text .. "- "
                else
                    text = text .. "d "
                end
                text = text .. toDate(file.mtime):padRight(12) .. " " .. filename .. "\n"
            end

            return text
        end
    },
    mkdir = {
        "mkdir <dirname> - Make directories",
        function(self, fs, dirname)
            local file = fs.cwd

            if not dirname then
                return computer.commands.mkdir[1]
            end
            if dirname == "." then
                return "Unable to create directory '.'"
            elseif dirname == ".." then
                return "Unable to create directory '..'"
            elseif fs.cwd == fs.root and dirname == "mnt" then
                return "Unable to create directory 'mnt'"
            else
                if dirname:startsWith("/") then
                    file = fs.root
                end

                local path, count = dirname:split("/")
                for index, _dirname in pairs(path) do
                    count = count - 1

                    if _dirname ~= "" then
                        if file.type ~= "dir" then
                            return dirname .. " isn't a directory"
                        end
                        if file.files[_dirname] ~= nil then
                            file = file.files[_dirname]
                        elseif count == 0 then
                            if file == fs.root and _dirname == "mnt" then
                                return "Unable to create directory 'mnt'"
                            end

                            local parent = file
                            file = {
                                type = "dir",

                                parent = parent,
                                name = _dirname,

                                ctime = game.tick,
                                mtime = game.tick,
                                atime = game.tick,

                                files = {}
                            }
                            parent.files[_dirname] = file
                        else
                            return dirname .. " no such file or directory"
                        end
                    end
                end
            end

            return file
        end
    },
    mv = {
        "mv <srcfile> <dstfile> - move a file",
        function(self, fs, srcfile, dstfile)
            if not srcfile or not dstfile then
                return computer.commands.mv[1]
            end

            local content, success = self:exec("cat " .. srcfile)

            if not success then
                return content
            end

            local file = self:exec("touch " .. dstfile)
            if type(file) == "string" then
                return file
            end

            file.text = content

            self:exec("rm " .. srcfile)
        end
    },
    position = {
        "position - Return the current computer position",
        function(self, fs)
            return table.tostring(fs.entity.position)
        end
    },
    pwd = {
        "pwd - print name of current/working directory",
        function(self, fs)
            local text = ""
            local dir = fs.cwd

            while dir.parent ~= dir do
                text = "/" .. dir.name .. text
                dir = dir.parent
            end

            return text
        end
    },
    rm = {
        "rm <file> - remove files or directories",
        function(self, fs, filename)
            local file = fs.cwd

            if not filename then
                return computer.commands.rm[1]
            end
            if filename == "." then
                return "Unable to delete directory '.'"
            elseif filename == ".." then
                return "Unable to delete directory '..'"
            elseif fs.cwd == fs.root and filename == "mnt" then
                return "Unable to delete virtual directory 'mnt'"
            else
                if filename:startsWith("/") then
                    file = fs.root
                end

                for index, _dirname in pairs(filename:split("/")) do
                    if _dirname ~= "" then
                        if file.type ~= "dir" then
                            return filename .. " isn't a directory"
                        end
                        if file.files[_dirname] ~= nil then
                            file = file.files[_dirname]
                        else
                            return filename .. " no such file or directory"
                        end
                    end
                end
                if file == fs.root then
                    return "Unable to delete root directory"
                else
                    local parent = fs.cwd
                    while parent.parent ~= parent do
                        if parent == file then
                            fs.cwd = file.parent
                            break
                        end
                        parent = parent.parent
                    end
                    file.parent.files[file.name] = nil
                end
            end
        end
    },
    run = {
        "run <file> - Run a script file",
        function(self, fs, filename, ...)
            local file = fs.cwd

            if not filename then
                return computer.commands.run[1]
            end
            if fs.process ~= nil then
                return "Script already running"
            end

            if type(filename) == "string" then
                if filename == "." then
                    return "Unable to run directory '.'"
                elseif filename == ".." then
                    return "Unable to run directory '..'"
                else
                    if filename:startsWith("/") then
                        file = fs.root
                    end

                    for index, _dirname in pairs(filename:split("/")) do
                        if _dirname ~= "" then
                            if file.type ~= "dir" then
                                return filename .. " isn't a directory"
                            end
                            if file.files[_dirname] ~= nil then
                                file = file.files[_dirname]
                            else
                                return filename .. " no such file or directory"
                            end
                        end
                    end
                    if file.type ~= "file" then
                        return filename .. " isn't a file"
                    end
                end
            else
                file = filename
            end

            local env = {
                apis = {},
                prototypes = {},
                proxies = {
                }
            };
            fs.apis = {};
            fs.env = env;
            for index, api in pairs(computer.apis) do
                if apiAllowed(api, fs.entity) then
                    local validator = {
                        apiPrototype = api,
                        entity = fs.entity,
                        apiAllowed = apiAllowed,
                        validate = function(self)
                            return self.apiAllowed(self.apiPrototype, self.entity)
                        end
                    };
                    table.insert(fs.apis, validator)

                    local player = self:getPlayer()
                    if not env.apis[api.name] then
                        env.apis[api.name], env.proxies[api.name] = self:loadApis(api, {
                            -- public properties
                            __name = api.name,
                            __entity = fs.entity,
                            __entityStructure = searchInTable(global.structures, fs.entity, 'entity'),
                            __player = player,
                            __env = env.proxies,

                            -- public methods
                            __getGameTick = function()
                                return game.tick
                            end
                        }, {
                            -- Empty object (its a proxy to protected API)
                        }, env)
                    end

                    if not env.prototypes[api.name] then env.prototypes[api.name] = {} end
                    for index, value in pairs(api.prototype or {}) do
                        if type(index) == "string" then
                            env.apis[api.name][index] = deepcopy(value[2])
                            if not index:startsWith("_") then
                                env.prototypes[api.name][index] = true
                            end
                        end
                    end
                    for event_name, callback in pairs(api.events or {}) do
                        if type(event_name) == "string" and type(callback) == "function" then
                            local eventEmitter = {
                                processId = table.id(env),
                                computer = self,
                                api = env.apis[api.name],
                                callback = callback,
                                emit = function(self, process, event, ...)
                                    if process == self.processId then
                                        local success, result = pcall(self.callback, self.api, event, ...)
                                        if not success then
                                            self.computer.data.output = self.computer.data.output .. "Error:\n" .. result .. "\n"
                                        end
                                    end
                                end
                            };
                            self:registerEmitter(event_name, eventEmitter)
                        end
                    end
                    if type(env.apis[api.name].__init) == "function" then
                        local success, result = pcall(env.apis[api.name].__init, env.apis[api.name])
                        if not success then
                            return "Error:\n" .. result
                        end
                    end
                end
            end
            file.atime = game.tick;
            fs.file = file

            env.proxies.args = {...}
            deepcopy(baseEnv, env.proxies)

            local fct, err = load(file.text, nil, "t", env.proxies)

            if err ~= nil then
                return "Error:\n" .. err
            end

            fs.process = table.id(env)
            self:openGui("output").file = file
            self.data.output = "> run " .. file.name
            for index, value in pairs({...}) do
                self.data.output = self.data.output .. " " .. value
            end
            self.data.output = self.data.output .. "\nRunning...\n"
            local success, result = pcall(fct)
            if not success then
                self:exec("stop", false)
                self.data.output = self.data.output .. "Error:\n" .. result
            end
            self.gui:print(self.data.output)
        end
    },
    stop = {
        "stop - Stop all process",
        function(self, fs)
            self:raise_event("on_script_kill", fs.process)
            fs.process = nil
            fs.output = ""
            self:clearEmitters()
        end
    },
    time = {
        "time - Return the current in-game time",
        function(self)
            local time = (game.tick % 25000) / 25000 * 24
            local h = math.floor(time)
            local m = math.floor((time - h) * 60)
            local s = math.floor((((time - h) * 60) - m) * 60)

            h = h + 12
            if h >= 24 then
                h = h - 24
            end
            if h < 10 then
                h = '0' .. h
            end
            if m < 10 then
                m = '0' .. m
            end
            if s < 10 then
                s = '0' .. s
            end
            return h .. ':' .. m .. ':' .. s
        end
    },
    touch = {
        "touch <filename> - Change file timestamps",
        function(self, fs, filename)
            local file = fs.cwd

            if not filename then
                return computer.commands.touch[1]
            end
            if filename == "." then
                return "Unable to touch directory '.'"
            elseif filename == ".." then
                return "Unable to touch directory '..'"
            elseif fs.cwd == fs.root and filename == "mnt" then
                return "Unable to touch virtual directory 'mnt'"
            else
                if filename:startsWith("/") then
                    file = fs.root
                end

                local path, count = filename:split("/")
                for index, _dirname in pairs(path) do
                    count = count - 1

                    if _dirname ~= "" then
                        if file.type ~= "dir" then
                            return filename .. " isn't a directory"
                        end
                        if file.files[_dirname] ~= nil then
                            file = file.files[_dirname]
                        elseif count == 0 then
                            if file == fs.root and _dirname == "mnt" then
                                return "Unable to touch virtual directory 'mnt'"
                            end
                            local parent = file
                            file = {
                                type = "file",

                                parent = parent,
                                name = _dirname,

                                ctime = game.tick,
                                mtime = game.tick,
                                atime = game.tick,

                                text = ""
                            }
                            parent.files[_dirname] = file
                        else
                            if file == fs.root and _dirname == "mnt" then
                                file = {
                                    type = "dir",
                                    files = {}
                                }
                                for label, _computer in pairs(self:getLabeleld()) do
                                    file.files[label] = _computer.data.root
                                end

                            else
                                return filename .. " no such file or directory"
                            end
                        end
                    end
                end
            end

            file.mtime = game.tick;
            file.atime = game.tick;
            return file
        end
    },
    tree = {
        "tree - list contents of directories in a tree-like format",
        function(self, fs)
            local function tree(folder, prefix)
                local file
                local text = ""
                local count = table.len(folder.files)

                for filename, fd in pairs(folder.files) do
                    count = count - 1
                    file = folder.files[filename]

                    if count == 0 then
                        if file.type == "dir" and table.len(file.files) > 0 then
                            text = text .. prefix .. "└─┬ " .. filename .. "\n"
                            text = text .. tree(file, prefix .. "      ")
                        else
                            text = text .. prefix .. "└── " .. filename .. "\n"
                        end
                    else
                        if file.type == "dir" and table.len(file.files) > 0 then
                            text = text .. prefix .. "├─┬ " .. filename .. "\n"
                            text = text .. tree(file, prefix .. "│   ")
                        else
                            text = text .. prefix .. "├── " .. filename .. "\n"
                        end
                    end
                end
                return text
            end

            local text = ".\n"
            if fs.cwd == fs.root then
                local labels = self:getLabeleld()
                local count = table.len(labels)

                if table.len(fs.root.files) > 0 then
                    if count == 0 then
                        text = text .. "├── mnt\n"
                    else
                        text = text .. "├─┬ mnt\n"
                        for label, v in pairs(labels) do
                            count = count - 1
                            if count > 0 then
                                text = text .. "│   ├── " .. label .. "\n"
                            else
                                text = text .. "│   └── " .. label .. "\n"
                            end
                        end
                    end
                else
                    if count == 0 then
                        text = text .. "├── mnt\n"
                    else
                        text = text .. "├─┬ mnt\n"
                        for label, v in pairs(labels) do
                            count = count - 1
                            if count > 0 then
                                text = text .. "      ├── " .. label .. "\n"
                            else
                                text = text .. "      └── " .. label .. "\n"
                            end
                        end
                    end
                end
            end
            text = text .. tree(fs.cwd, "")

            return text
        end
    },
    waypoint = {
        "waypoint - Edit saved waypoints",
        function(self, fs)
            self:openGui("waypoint")
        end
    }
}