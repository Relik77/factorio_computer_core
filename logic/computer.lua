require("logic.util")

if not global.computerGuis then
    global.computerGuis = {}
end
if not global.computers then
    global.computers = {}
end
if not global.waypoints then
    global.waypoints = {}
end

function apiAllowed(api, entity)
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

computer = {
    apis = {},

    commands = {},

    guis = {},

    _mt = {
        __eq = function(a, b)
            return a.data == b.data
        end
    },

    new = function(entity)
        local obj = {
            valid = true,

            data = nil,
            gui = nil,
            history = ""
        }

        for index, value in pairs(computer) do
            if index ~= "_mt" then
                obj[index] = value
            else
                setmetatable(obj, value)
            end
        end

        local index
        if entity.type == "player" then
            for i, computer in pairs(global.computers) do
                if computer.entityIsPlayer and computer.entityIsPlayer == entity.player.index then
                    index = i
                end
            end
        else
            index = searchIndexInTable(global.computers, entity, "entity")
        end
        if index then
            obj.data = global.computers[index]
            if not obj.data.entity or not obj.data.entity.valid then
                if obj.data.entityIsPlayer then
                    obj.data.entity = entity
                else
                    global.computers[index] = nil
                    return nil
                end
            end
        else
            obj.data = {
                entity = entity,
                entityIsPlayer = nil,

                label = nil,

                player = nil,
                output = "",
                process = nil,

                events = {},
                apis = {},
                env = {},

                root = {
                    type = "dir",

                    parent = nil,

                    ctime = game.tick,
                    mtime = game.tick,
                    atime = game.tick,

                    files = {}
                },
            }
            if entity.type == "player" then
                obj.data.entityIsPlayer = entity.player.index
            end
            obj.data.root.parent = obj.data.root
            obj.data.cwd = obj.data.root

            if not global.computers then
                global.computers = {}
            end
            table.insert(global.computers, obj.data)
        end

        obj.history = computer.commands.pwd[2](obj, obj.data) .. "> "

        return obj
    end,

    load = function(data)
        if not data.entity or not data.entity.valid then
            return nil
        end

        local obj = {
            valid = true,

            data = data,
            gui = nil,
            history = ""
        }

        for index, value in pairs(computer) do
            if index ~= "_mt" then
                obj[index] = value
            else
                setmetatable(obj, value)
            end
        end

        obj.history = computer.commands.pwd[2](obj, obj.data) .. "> "

        return obj
    end,

    getPlayer = function(self)
        if self.data.player then
            return game.players[self.data.player]
        else
            return nil
        end
    end,

    setPlayer = function(self, player)
        if player ~= nil then
            self.data.player = player.index
        else
            self.data.player = nil
        end
    end,

    getLabeleld = function(self)
        local player = self:getPlayer()
        local labels = {}

        if player then
            for i, computerData in pairs(global.computers) do
                if not computerData.entityIsPlayer or computerData.entityIsPlayer == player.index then
                    local _computer = computer.load(computerData)
                    if _computer then
                        local computerPlayer = _computer:getPlayer()
                        if computerPlayer and (computerPlayer.force == player.force or computerPlayer.force.get_friend(player.force)) and computerData.label then
                            labels[computerData.label] = _computer
                        end
                    end
                end
            end
        end

        return labels
    end,

    getComputers = function(self, label)
        local player = self:getPlayer()
        local computers = {}

        if player then
            for i, computerData in pairs(global.computers) do
                local _computer = computer.load(computerData)
                if _computer then
                    local computerPlayer = _computer:getPlayer()
                    if computerPlayer and (computerPlayer.force == player.force or computerPlayer.force.get_friend(player.force)) and (not label or computerData.label == label) then
                        table.insert(computers, _computer)
                    end
                end
            end
        end

        return computers
    end,

    registerEmitter = function(self, name, eventEmitter)
        if not self.data.eventEmitters then
            self.data.eventEmitters = {}
        end

        table.insert(self.data.eventEmitters, {
            name = name,
            emitter = eventEmitter
        })
    end,

    raise_event = function(self, event_name, process, ...)
        if self.data.entity.electric_buffer_size and self.data.entity.energy == 0 then
            return
        end

        for index, eventEmitter in pairs(self.data.eventEmitters or {}) do
            if eventEmitter.name == event_name then
                eventEmitter.emitter:emit(process, ...)
            end
        end
    end,

    clearEmitters = function(self)
        self.data.eventEmitters = {}
    end,

    runScript = function(self, fs, script, script_name, ...)
        local env = {
            apis = {},
            prototypes = {},
            proxies = {
            },
            file = {
                type = "file",

                parent = fs.root,
                name = "temp_" .. game.tick,

                ctime = game.tick,
                mtime = game.tick,
                atime = game.tick,

                text = ""
            },
            filesLoaded = {}
        }
        local err

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

                --local player = self:getPlayer()
                if not env.apis[api.name] then
                    env.apis[api.name], env.proxies[api.name] = self:loadAPI(api, {
                    -- public properties
                        __name = api.name,
                        __entity = fs.entity,
                        __entityStructure = searchInTable(global.structures, fs.entity, 'entity'),
                    --__player = player,
                    --__env = env.proxies,
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

        env.proxies.args = {...}
        deepcopy(baseEnv, env.proxies)

        if type(script) == "string" then
            script, err = load(script, nil, "bt", env.proxies)
        end

        fs.process = table.id(env)
        self.data.output = "> run " .. script_name
        for index, value in pairs({...}) do
            self.data.output = self.data.output .. " " .. value
        end
        if err ~= nil then
            self.data.output = "Error:\n" .. string.gsub(err, "%[string.+%]:", script_name .. ":")
            if self.gui then
                self.gui:print(self.data.output)
            end
            return "Error\n" .. err
        else
            self.data.output = self.data.output .. "\nRunning...\n"
        end

        local success, result = pcall(script)
        if not success then
            self:exec("stop", false)
            self.data.output = self.data.output .. "Error:\n" .. result
        end
        if self.gui then
            self.gui:print(self.data.output)
        end
        return result, env
    end,

    loadAPI = function(self, api, item, proxy, env)
        --local player = self:getPlayer()
        setmetatable(item, {
        -- protected metatable
            __index = setmetatable({
            -- Empty object (this is a proxy to the private properties of the API)
            }, {
            -- private properties
                env = env,
                computer = self,
            --player = player,

                getters = {
                    __player = function(self)
                        return self.computer:getPlayer()
                    end,
                    __env = function(self)
                        return self.env.proxies
                    end,
                    __getAPI = function(self)
                        return function(name)
                            return self.env.proxies[name]
                        end
                    end,
                    __getOutput = function(self)
                        return function()
                            return self.computer.data.output
                        end
                    end,
                    __setOutput = function(self)
                        return function(text)
                            self.computer.data.output = text
                            local gui = searchInTable(global.computerGuis, self.computer.data, "os", "data")
                            if gui and gui.print then
                                gui:print(self.computer.data.output)
                            end
                        end
                    end,
                    __getInput = function(self)
                        return function()
                            local gui = searchInTable(global.computerGuis, self.computer.data, "os", "data")
                            if gui and gui.read then
                                if not gui:read():startsWith(self.computer.data.output) then
                                    if gui and gui.print then
                                        gui:print(self.computer.data.output)
                                    end
                                end

                                return gui:read():sub(#self.computer.data.output + 1);
                            end
                        end
                    end,
                    __setInput = function(self)
                        return function(text)
                            local gui = searchInTable(global.computerGuis, self.computer.data, "os", "data")
                            if gui and gui.print then
                                gui:print(self.computer.data.output .. text, true)
                            end
                        end
                    end,
                    __getLabel = function(self)
                        return function()
                            return self.computer.data.label
                        end
                    end,
                    __setLabel = function(self)
                        return function(label)
                            self.computer.data.label = label
                        end
                    end,
                    __getID = function(self)
                        return function()
                            return table.id(self.computer.data)
                        end
                    end,
                    __emit = function(self)
                        return function(label, event_name, ...)
                            for index, computer in pairs(self.computer:getComputers(label)) do
                                if computer.data and computer.data.process then
                                    computer:raise_event(event_name, computer.data.process, ...)
                                end
                            end
                        end
                    end,
                    __broadcast = function(self)
                        return function(event_name, ...)
                            for index, computer in pairs(self.computer:getComputers()) do
                                if computer.data and computer.data.process then
                                    computer:raise_event(event_name, computer.data.process, ...)
                                end
                            end
                        end
                    end,
                    __getWaypoint = function(self)
                        return function(name)
                            if not global.waypoints then
                                global.waypoints = {}
                            end
                            for index, waypoint in pairs(global.waypoints) do
                                if waypoint.force == self.computer:getPlayer().force and waypoint.name == name then
                                    return waypoint
                                end
                            end
                            return nil
                        end
                    end,
                    __getGameTick = function(self)
                        return function()
                            return game.tick
                        end
                    end,
                    __require = function(self)
                        return function(filename)
                            local file = self.env.file.parent

                            assert(type(filename) == "string")
                            assert(filename ~= ".")
                            assert(filename ~= "..")

                            if filename:startsWith("/") then
                                file = self.computer.data.root
                            end

                            for index, _dirname in pairs(filename:split("/")) do
                                if _dirname ~= "" then
                                    assert(file.type == "dir", filename .. " isn't a directory")
                                    assert(file.files[_dirname] ~= nil, filename .. " no such file or directory")
                                    file = file.files[_dirname]
                                end
                            end
                            assert(file.type == "file", filename .. " isn't a file")

                            -- game.print(table.tostring(self.env.filesLoaded))
                            if not getmetatable(self.env.filesLoaded) then
                                self.env.filesLoaded = {}
                                setmetatable(self.env.filesLoaded, {});
                            end
                            for index, lib in ipairs(self.env.filesLoaded) do
                                if lib.file == file then
                                    return lib.result
                                end
                            end
                            file.atime = game.tick;

                            local fct, err = load(file.text, nil, "t", self.env.proxies)
                            assert(err == nil, err)
                            local success, result = pcall(fct)
                            assert(success == true, result)

                            table.insert(self.env.filesLoaded, { file = file, result = result })
                            return result
                        end
                    end,
                    __readFile = function(self)
                        return function(filename)
                            local file = self.env.file.parent

                            assert(type(filename) == "string")
                            assert(filename ~= ".")
                            assert(filename ~= "..")

                            if filename:startsWith("/") then
                                file = self.computer.data.root
                            end

                            for index, _dirname in pairs(filename:split("/")) do
                                if _dirname ~= "" then
                                    assert(file.type == "dir", filename .. " isn't a directory")
                                    assert(file.files[_dirname] ~= nil, filename .. " no such file or directory")
                                    file = file.files[_dirname]
                                end
                            end
                            assert(file.type == "file", filename .. " isn't a file")

                            file.atime = game.tick;
                            return file.text;
                        end
                    end,
                    __writeFile = function(self)
                        return function(filename, ...)
                            local file = self.env.file.parent

                            assert(type(filename) == "string")
                            assert(filename ~= ".")
                            assert(filename ~= "..")

                            if filename:startsWith("/") then
                                file = self.computer.data.root
                            end

                            local parentFile = file.parent
                            for index, _dirname in pairs(filename:split("/")) do
                                if _dirname ~= "" then
                                    if not file.type then
                                        file.type = "dir"
                                        file.files = {}
                                        file.parent.files[file.name] = file
                                    end
                                    assert(file.type == "dir", filename .. " isn't a directory")
                                    parentFile = file
                                    file = file.files[_dirname]
                                    if not file then
                                        file = {
                                            type = nil,

                                            parent = parentFile,
                                            name = _dirname,

                                            ctime = game.tick,
                                            mtime = game.tick,
                                            atime = game.tick
                                        }
                                    end
                                end
                            end
                            if not file.type then
                                file.type = "file"
                                file.text = ""
                                file.parent.files[file.name] = file
                            end
                            assert(file.type == "file", filename .. " isn't a file")

                            file.mtime = game.tick;
                            file.atime = game.tick;
                            file.text = "";

                            for index, text in pairs({...}) do
                                if type(text) == "table" then
                                    text = table.tostring(text)
                                end
                                file.text = file.text .. text
                            end
                        end
                    end,
                    __removeFile = function(self)
                        return function(filename)
                            local file = self.env.file.parent

                            assert(type(filename) == "string")
                            assert(filename ~= ".")
                            assert(filename ~= "..")

                            if filename:startsWith("/") then
                                file = self.computer.data.root
                            end

                            for index, _dirname in pairs(filename:split("/")) do
                                if _dirname ~= "" then
                                    assert(file.type == "dir", filename .. " isn't a directory")
                                    assert(file.files[_dirname] ~= nil, filename .. " no such file or directory")
                                    file = file.files[_dirname]
                                end
                            end
                            assert(file.type == "file", filename .. " isn't a file")

                            file.parent.files[file.name] = nil
                        end
                    end,
                    __fileExist = function(self)
                        return function(filename)
                            local file = self.env.file.parent

                            assert(type(filename) == "string")
                            assert(filename ~= ".")
                            assert(filename ~= "..")

                            if filename:startsWith("/") then
                                file = self.computer.data.root
                            end

                            for index, _dirname in pairs(filename:split("/")) do
                                if _dirname ~= "" then
                                    assert(file.type == "dir", filename .. " isn't a directory")
                                    file = file.files[_dirname]
                                    if not file then
                                        return false
                                    end
                                end
                            end
                            assert(file.type == "file", filename .. " isn't a file")
                            return true
                        end
                    end
                },

            -- access to private properties
                __index = function(table, key)
                    local self = getmetatable(table)
                    if type(self.getters[key]) == "function" then
                        return self.getters[key](self)
                    end
                    -- __init is an optional api function
                    return self.getters[key]
                end,

            -- Set protected metatable 'Read-Only'
                __newindex = function(self, key)
                    assert(false, "Can't edit protected metatable")
                end
            }),

        -- The API isn't 'Read-Only'

        -- Protect metatable (blocks access to the metatable)
            __metatable = "this is the protected API " .. api.name
        })

        setmetatable(proxy, {
        -- protected metatable
            __index = setmetatable({
            -- Empty object (this is a proxy to the private properties of the proxy)
            }, {
            -- private properties
                env = env,
                api = item,
                apiPrototype = api,

            -- access to private properties
                __index = function(tbl, key)
                    local self = getmetatable(tbl)
                    assert(self.env.prototypes[self.apiPrototype.name][key], self.apiPrototype.name .. " doesn't have key " .. key)
                    if type(self.api[key]) == "function" then
                        return function(...)
                            return self.api[key](self.api, ...)
                        end
                    end
                    return self.api[key]
                end,

            -- Set protected metatable 'Read-Only'
                __newindex = function(self, key)
                    assert(false, "Can't edit protected metatable")
                end
            }),

        -- Set Proxy 'Read-Only'
            __newindex = function(self, key)
                assert(false, "Can't edit API " .. self.apiPrototype.name)
            end,

        -- Protect metatable (blocks access to the metatable)
            __metatable = "this is the API " .. api.name
        })

        return item, proxy
    end,

    openGui = function(self, type, player)
        if not global.computerGuis then
            global.computerGuis = {}
        end
        if self.data.output ~= "" then
            type = "output"
        end
        assert(computer.guis[type] ~= nil)

        local curentPlayer = self:getPlayer()
        if not player then
            player = curentPlayer
        end

        if curentPlayer and curentPlayer ~= player then
            if global.computerGuis[curentPlayer.index] and global.computerGuis[curentPlayer.index].os == self then
                player.print("Another player is already connected to this computer")
                return nil
            elseif self:getPlayer().force ~= player.force and not self:getPlayer().force.get_friend(player.force) then
                player.print("Can't connect to a computer of an enemy force")
                return nil
            end
        end

        self:closeGui()
        self:setPlayer(player)

        self.gui = computer.guis[type].new(player, self)
        if type == "output" then
            self.gui.file = self.data.file
        end
        global.computerGuis[player.index] = self.gui;
        return self.gui
    end,

    closeGui = function(self)
        local player = self:getPlayer()
        local gui

        if self.gui then
            gui = self.gui
        elseif player then
            gui = global.computerGuis[player.index]
        end

        if gui then
            gui:destroy()
            if player then
                global.computerGuis[player.index] = nil
            end
        end
    end,

    exec = function(self, text, ...)
        text = text:trim()
        if text ~= "" then
            local params = text:split("%s", nil, true)
            local command = computer.commands[params[1]]

            if command == nil then
                return "Unknown command '" .. text .. "'\n"
            else
                table.remove(params, 1)

                for index, value in pairs({ ... }) do
                    table.insert(params, value)
                end
                return command[2](self, self.data, unpack(params))
            end
        end
    end,

    destroy = function(self)
        self.valid = false

        table.remove(global.computers, searchIndexInTable(global.computers, self.data.entity, "entity"))
    end
}

remote.add_interface("computer_core", {
    addComputerAPI = function(api)
        if type(api) == "string" then
            local construct, err = load(api, nil, "t", deepcopy(baseEnv, {
                debug = function(text)
                    if type(text) == "string" then
                        game.print("Debug: " .. text)
                    elseif type(text) == "table" then
                        game.print("Debug: " .. tostring(text) .. "\n" .. table.tostring(text))
                    else
                        game.print("Debug: " .. tostring(text))
                    end
                end,
                remote = remote
            }))
            assert(err == nil, err)
            local success, obj = pcall(construct)
            assert(success, obj)
            api = obj
        end
        table.insert(computer.apis, api)
    end,
    addEntityStructure = function(struct)
        table.insert(global.structures, struct)
    end
})