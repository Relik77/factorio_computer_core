require("mod-gui")
require("logic.util")
require("logic.computer")
require("logic.computerCommands")

require("logic.gui.computerGauntletGui")
require("logic.gui.computerConsoleGui")
require("logic.gui.computerEditorGui")
require("logic.gui.computerOutputGui")

require("logic.apis.term")
require("logic.apis.os")

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

    defines = defines,
}

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
                for index, validate in pairs(data.apis or {}) do
                    if not validate() then
                        item:exec("stop", false)
                        return
                    end
                end
                item:raise_event(event_name, event_data)
            else
                global.computers[index] = nil
            end
        end
    end
end

local function OnTick(event)
--    if not global.computers then global.computers = {} end
--
--    local count = 0
--    for k, v in pairs(global.computers) do
--        count = count + 1
--    end
--    game.print("computers : " .. count)
    raise_event("on_tick", event)
end

local function OnGuiClick(event)
    local name = event.element.name

    if name:match("^computer_") then
        if not global.computerGuis then global.computerGuis = {} end
        local player = game.players[event.player_index]

        if name == "computer_gauntlet_btn" then
            if not global.computerGuis[player.index] then
                computer.new(player.character):openGui("console", player)
            else
                global.computerGuis[player.index]:destroy()
                global.computerGuis[player.index] = nil
            end
        else
            if global.computerGuis[player.index] then
                global.computerGuis[player.index]:OnGuiClick(event)
            end
        end
    end
end

local function OnGuiTextChanged(event)
    local name = event.element.name

    if name:match("^computer_") then
        local player = game.players[event.player_index]

        if global.computerGuis[player.index] then
            global.computerGuis[player.index]:OnGuiTextChanged(event)
        end
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

script.on_event("open-computer", function (event)
    if not global.computerGuis then global.computerGuis = {} end
    local player = game.players[event.player_index]
    local technology = player.force.technologies["computer-gauntlet-technology"]

    if technology and technology.valid and technology.researched and player.selected and player.selected.type ~= "player" then
        local distance = getDistance(player.position, player.selected.position)
        if distance <= 10 and supportedEntity(player.selected) then
            if not global.computerGuis[player.index] then
                player.print("openGui type 'console' for player: " .. player.name)
                computer.new(player.selected):openGui("console", player)
            else
                global.computerGuis[player.index]:destroy()
                global.computerGuis[player.index] = nil
            end
        end
    end
end)

script.on_event(defines.events.on_tick, OnTick)

script.on_event(defines.events.on_gui_click, OnGuiClick)
script.on_event(defines.events.on_gui_text_changed, OnGuiTextChanged)

script.on_event(defines.events.on_player_joined_game, OnPlayerJoinedGame)
script.on_event(defines.events.on_player_left_game, OnPlayerLeft)

script.on_event(defines.events.on_research_finished, OnResearchFinished)
script.on_event(defines.events.on_player_changed_force, OnPlayerChangedForce)
