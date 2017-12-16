require("mod-gui")
require("logic.util")
require("logic.computer")
require("logic.computerCommands")

require("logic.gui.computerGauntletGui")
require("logic.gui.computerConsoleGui")
require("logic.gui.computerEditorGui")
require("logic.gui.computerOutputGui")
require("logic.gui.computerWaypointGui")

require("logic.apis.term")
require("logic.apis.os")
require("logic.apis.lan")
require("logic.apis.wlan")
require("logic.apis.speaker")

baseEnv = {
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
    assert = assert,

    defines = defines,
}

local function struct_create_or_revive(entity_type, surface, area, position, force)
    local found_ghost = false
    local ghosts = surface.find_entities_filtered {
        area = area,
        name = "entity-ghost",
        force = force }
    for _, each_ghost in pairs(ghosts) do
        if each_ghost.valid and each_ghost.ghost_name == entity_type then
            if found_ghost then
                each_ghost.destroy()
            else
                each_ghost.revive()
                if not each_ghost.valid then
                    found_ghost = true
                else
                    each_ghost.destroy()
                end
            end
        end
    end

    if found_ghost then
        local entity = surface.find_entities_filtered {
            area = area,
            name = entity_type,
            force = force,
            limit = 1
        }[1]
        if entity then
            entity.direction = defines.direction.south
            entity.teleport(position)
            return entity
        end
    else
        local reals = surface.find_entities_filtered {
            area = area,
            name = entity_type,
            limit = 1
        }
        if #reals == 1 then
            return reals[1]
        end

        return surface.create_entity {
            name = entity_type,
            position = position,
            force = force,
            fast_replace = true
        }
    end
end

local function raise_event(event_name, event_data)
    if not global.computers then
        global.computers = {}
    end

    for index, data in pairs(global.computers) do
        if not data.entity or (not data.entity.valid and not data.entityIsPlayer) then
            global.computers[index] = nil
        elseif data.process ~= nil then
            local item = computer.load(data)
            if item then
                for index, validator in pairs(data.apis or {}) do
                    if not validator:validate() then
                        item:exec("stop", false)
                        return
                    end
                    if not getmetatable(data.env.proxies[validator.apiPrototype.name]) then
                        if data.env then
                            item:loadAPI(validator.apiPrototype, data.env.apis[validator.apiPrototype.name], data.env.proxies[validator.apiPrototype.name], data.env)
                        end
                    end
                end
                item:raise_event(event_name, data.process, event_data)
            else
                global.computers[index] = nil
            end
        end
    end
end

local function OnTick(event)
    for index, gui in pairs(global.computerGuis or {}) do
        if type(gui.OnTick) == "function" then
            gui:OnTick(event)
        end
    end

    raise_event("on_tick", event)
end

local function stopAllCumputerScripts()
    if not global.computers then
        global.computers = {}
    end

    for index, data in pairs(global.computers) do
        if not data.entity or (not data.entity.valid and not data.entityIsPlayer) then
            global.computers[index] = nil
        elseif data.process ~= nil then
            local item = computer.load(data)
            if item then
                item:exec("stop", false)
            else
                global.computers[index] = nil
            end
        end
    end
end

local function OnConfigurationChanged(data)
    local mod_change = data.mod_changes["computer_core"]
    if not mod_change then return end
    if mod_change.old_version == nil or mod_change.new_version == nil then return end
    if not global.computers then global.computers = {} end
    if not global.structures then global.structures = {} end

    local old_version = Version(mod_change.old_version)
    local new_version = Version(mod_change.new_version)

    if new_version:isLower(old_version) then
        game.print("Computer Core: WARNING, current version is lower previous version. This can lead to risky behavior. All scripts were stopped for security.")
        return stopAllCumputerScripts()
    end
    if old_version:isLower("1.2.1") and not new_version:isLower("1.2.1") then
        game.print("Computer Core: Configuration changed, running scrits need to be stop. Please restart them manually and sorry for inconvenience :/")
        stopAllCumputerScripts()
    end
    if old_version:isLower("1.3.1") and not new_version:isLower("1.3.1") then
        -- Computer Entity Type Changed
        for index, struct in pairs(global.structures) do
            if struct.type == "computer" then
                for index, data in pairs(global.computers) do
                    if data.entity == struct.entity then
                        -- Update Entity
                        struct.sub.lamp = struct.entity
                        struct.sub.lamp.get_or_create_control_behavior().circuit_condition = {
                            condition = {
                                comparator = "=",
                                first_signal = {type = "virtual", name = "signal-everything" },
                                constant = 0
                            }
                        }
                        struct.sub.lamp.destructible = false

                        struct.entity = struct_create_or_revive(
                        "computer-interface-entity",
                        data.entity.surface, -- surface
                        { { data.entity.position.x - 1, data.entity.position.y - 1 }, { data.entity.position.x + 1, data.entity.position.y + 1 } }, -- ghost search area
                        data.entity.position, -- position
                        data.entity.force
                        )
                        data.entity = struct.entity

                        -- New Entity "speaker"
                        struct.sub.speaker = struct_create_or_revive(
                        "computer-speaker",
                        data.entity.surface, -- surface
                        { { data.entity.position.x - 1.5, data.entity.position.y - 1 }, { data.entity.position.x + 1.5, data.entity.position.y + 1 } }, -- ghost search area
                        { x = data.entity.position.x, y = data.entity.position.y }, -- position
                        data.entity.force
                        )
                        struct.sub.speaker.destructible = false


                        struct.sub.speaker_combinator = struct_create_or_revive(
                        "computer-speaker-combinator",
                        data.entity.surface, -- surface
                        { { data.entity.position.x - 1.5, data.entity.position.y - 1 }, { data.entity.position.x + 1.5, data.entity.position.y + 1 } }, -- ghost search area
                        { x = data.entity.position.x, y = data.entity.position.y }, -- position
                        data.entity.force
                        )
                        struct.sub.speaker_combinator.destructible = false

                        if data.process then
                            -- Update validator
                            for index, validator in pairs(data.apis or {}) do
                                validator.entity = data.entity
                                if validator.apiPrototype.name == "lan" then
                                    for _, api in pairs(computer.apis) do
                                        if api.name == "lan" then
                                            validator.apiPrototype = api
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        break
                    end
                end
            end
        end
    end
end

local function OnGuiClick(event)
    local name = event.element.name

    if name:match("^computer_") then
        if not global.computerGuis then
            global.computerGuis = {}
        end
        local player = game.players[event.player_index]

        if name == "computer_gauntlet_btn" then
            if not global.computerGuis[player.index] then
                computer.new(player.character):openGui("console", player)
            else
                global.computerGuis[player.index]:destroy()
                global.computerGuis[player.index] = nil
            end
        else
            if global.computerGuis[player.index] and type(global.computerGuis[player.index].OnGuiClick) == "function" then
                global.computerGuis[player.index]:OnGuiClick(event)
            end
        end
    end
end

local function OnGuiTextChanged(event)
    local name = event.element.name

    if name:match("^computer_") then
        local player = game.players[event.player_index]

        if global.computerGuis[player.index] and type(global.computerGuis[player.index].OnGuiTextChanged) == "function" then
            global.computerGuis[player.index]:OnGuiTextChanged(event)
        end
    end
end

local function OnGuiSelectionStateChanged(event)
    local name = event.element.name

    if name:match("^computer_") then
        local player = game.players[event.player_index]

        if global.computerGuis[player.index] and type(global.computerGuis[player.index].OnGuiSelectionStateChanged) == "function" then
            global.computerGuis[player.index]:OnGuiSelectionStateChanged(event)
        end
    end
end

local function OnGuiCheckedStateChanged(event)
    local name = event.element.name

    if name:match("^computer_") then
        local player = game.players[event.player_index]

        if global.computerGuis[player.index] and type(global.computerGuis[player.index].OnGuiCheckedStateChanged) == "function" then
            global.computerGuis[player.index]:OnGuiCheckedStateChanged(event)
        end
    end
end

local function OnGuiElemChanged(event)
    local name = event.element.name

    if name:match("^computer_") then
        local player = game.players[event.player_index]

        if global.computerGuis[player.index] and type(global.computerGuis[player.index].OnGuiElemChanged) == "function" then
            global.computerGuis[player.index]:OnGuiElemChanged(event)
        end
    end
end

local function OnBuiltEntity(event)
    local entity = event.created_entity

    if not (entity and entity.valid) then
        return
    end
    if not global.structures then
        global.structures = {}
    end

    if entity.name == "computer-interface-entity" then
        local struct = {
            type = "computer",
            entity = entity,
            sub = {}
        }

        struct.sub.left_combinator = struct_create_or_revive(
        "computer-combinator",
        entity.surface, -- surface
        { { entity.position.x - 1.5, entity.position.y - 1 }, { entity.position.x + 0, entity.position.y + 1 } }, -- ghost search area
        { x = entity.position.x - 0.83, y = entity.position.y + 0.51 }, -- position
        entity.force
        )
        struct.sub.left_combinator.destructible = false

        struct.sub.right_combinator = struct_create_or_revive(
        "computer-combinator",
        entity.surface, -- surface
        { { entity.position.x + 0, entity.position.y - 1 }, { entity.position.x + 1.5, entity.position.y + 1 } }, -- ghost search area
        { x = entity.position.x + 0.76, y = entity.position.y + 0.51 }, -- position
        entity.force
        )
        struct.sub.right_combinator.destructible = false

        struct.sub.lamp = struct_create_or_revive(
        "computer-lamp",
        entity.surface, -- surface
        { { entity.position.x - 1.5, entity.position.y - 1 }, { entity.position.x + 1.5, entity.position.y + 1 } }, -- ghost search area
        { x = entity.position.x, y = entity.position.y }, -- position
        entity.force
        )
        struct.sub.lamp.get_or_create_control_behavior().circuit_condition = {
            condition = {
                comparator = "=",
                first_signal = {type = "virtual", name = "signal-everything" },
                constant = 0
            }
        }
        struct.sub.lamp.destructible = false

        struct.sub.speaker_combinator = struct_create_or_revive(
        "computer-speaker-combinator",
        entity.surface, -- surface
        { { entity.position.x - 1.5, entity.position.y - 1 }, { entity.position.x + 1.5, entity.position.y + 1 } }, -- ghost search area
        { x = entity.position.x, y = entity.position.y }, -- position
        entity.force
        )
        struct.sub.speaker_combinator.destructible = false

        struct.sub.speaker = struct_create_or_revive(
        "computer-speaker",
        entity.surface, -- surface
        { { entity.position.x - 1.5, entity.position.y - 1 }, { entity.position.x + 1.5, entity.position.y + 1 } }, -- ghost search area
        { x = entity.position.x, y = entity.position.y }, -- position
        entity.force
        )
        struct.sub.speaker.destructible = false

        table.insert(global.structures, struct)
    end
end

local function OnEntityDied(event)
    local entity = event.entity

    if not entity.valid then return end
    if global.structures then
        local index = searchIndexInTable(global.structures, entity, 'entity')
        local struct = global.structures[index]

        if not struct then return end

        if struct.sub then
            for key, subentity in pairs(struct.sub) do
                if subentity.valid then
                    subentity.destroy()
                end
                struct.sub[key] = nil
            end
        end
        global.structures[index] = nil
    end
end

local function OnPlayerJoinedGame(event)
    local player = game.players[event.player_index]
    local technology = player.force.technologies["computer-gauntlet-technology"]

    if technology and technology.valid and technology.researched then
        setGauntletBtn(player, true)
    end
end

local function OnPlayerLeft(event)
    local player = game.players[event.player_index]

    if global.computerGuis[player.index] then
        global.computerGuis[player.index]:destroy()
        global.computerGuis[player.index] = nil
    end
end

local function OnResearchFinished(event)
    local name = event.research.name;

    if name == "computer-gauntlet-technology" then
        for index, player in pairs(game.players) do
            setGauntletBtn(player, true)
        end
    end
end

local function OnPlayerChangedForce(event)
    local player = game.players[event.player_index]
    local technology = player.force.technologies["computer-gauntlet-technology"]

    setGauntletBtn(player, technology and technology.valid and technology.researched)
end

local function supportedEntity(entity)
    if not entity then
        return false
    end
    if entity.name == "computer-interface-entity" then
        return true
    end
    for index, api in pairs(computer.apis) do
        if type(api.entities) == "function" and api.entities(entity) then
            return true
        elseif type(api.entities) == "table" and table.contains(api.entities, entity.name) then
            return true
        elseif type(api.entities) == "string" then
            local fct, err = load(api.entities, nil, "t", baseEnv)
            assert(err == nil, err)
            local success, test = pcall(fct)
            assert(success, test)
            local success, result = pcall(test, entity)
            if success and result then
                return true
            end
        end
    end
    return false
end

local function OpenComputer(player, entity)
    if entity.electric_buffer_size and entity.energy == 0 then
        return
    end
    if not global.computerGuis then
        global.computerGuis = {}
    end
    local technology = player.force.technologies["computer-gauntlet-technology"]

    if technology and technology.valid and technology.researched and entity and entity.type ~= "player" then
        local distance = getDistance(player.position, entity.position)
        if distance <= 10 and supportedEntity(entity) then
            if not global.computerGuis[player.index] then
                computer.new(entity):openGui("console", player)
            else
                global.computerGuis[player.index]:destroy()
                global.computerGuis[player.index] = nil
            end
        end
    end
end

script.on_event("open-computer", function(event)
    local player = game.players[event.player_index]

    if player.selected then
        OpenComputer(player, player.selected)
    end
end)

script.on_event(defines.events.on_tick, OnTick)
script.on_configuration_changed(OnConfigurationChanged)

script.on_event(defines.events.on_gui_click, OnGuiClick)
script.on_event(defines.events.on_gui_text_changed, OnGuiTextChanged)
script.on_event(defines.events.on_gui_selection_state_changed, OnGuiSelectionStateChanged)
script.on_event(defines.events.on_gui_checked_state_changed, OnGuiCheckedStateChanged)
script.on_event(defines.events.on_gui_elem_changed, OnGuiElemChanged)

script.on_event(defines.events.on_built_entity, OnBuiltEntity)
script.on_event(defines.events.on_robot_built_entity, OnBuiltEntity)
script.on_event(defines.events.on_entity_died, OnEntityDied)
script.on_event(defines.events.on_pre_player_mined_item, OnEntityDied)
script.on_event(defines.events.on_robot_pre_mined, OnEntityDied)

script.on_event(defines.events.on_player_joined_game, OnPlayerJoinedGame)
script.on_event(defines.events.on_player_left_game, OnPlayerLeft)

script.on_event(defines.events.on_research_finished, OnResearchFinished)
script.on_event(defines.events.on_player_changed_force, OnPlayerChangedForce)
