require("logic.util")

if not global.computerGuis then global.computerGuis = {} end
if not global.computers then global.computers = {} end

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

            if not global.computers then global.computers = {} end
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

    registerEvent = function(self, name, callback)
        if not self.data.events then self.data.events = {} end

        table.insert(self.data.events, {
            name = name,
            callback = callback
        })
    end,

    raise_event = function(self, event_name, process, ...)
        for index, event in pairs(self.data.events) do
            if event.name == event_name then
                event.callback(process, ...)
            end
        end
    end,

    clearEvents = function(self)
        self.data.events = {}
    end,

    openGui = function(self, type, player)
        if not global.computerGuis then global.computerGuis = {} end
        if self.data.output ~= "" then
            type = "output"
        end
        assert(computer.guis[type] ~= nil)

        local curentPlayer = self:getPlayer()
        if not player then
            player = curentPlayer
        end

        if curentPlayer then
            player.print("computer.openGui type '" .. type .. "' for player: " .. player.name .. " used by " .. curentPlayer.name)
        else
            player.print("computer.openGui type '" .. type .. "' for player: " .. player.name .. " used by nobody")
        end

        if curentPlayer and curentPlayer ~= player then
            player.print("Another player is associed to this computer")
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

                for index, value in pairs({...}) do
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
                end
            }))
            assert(err == nil, err)
            local success, obj = pcall(construct)
            assert(success, obj)
            api = obj
        end
        table.insert(computer.apis, api)
    end
})