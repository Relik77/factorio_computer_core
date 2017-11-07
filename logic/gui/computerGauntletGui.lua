require("mod-gui")

function setGauntletBtn(player, show)
    local flow = mod_gui.get_button_flow(player)

    if show and not flow.computer_gauntlet_btn then
        flow.add({
            type = "sprite-button",
            name = "computer_gauntlet_btn",
            sprite = "item/computer-gauntlet-equipment",
            style = mod_gui.button_style
        })
    elseif not show and flow.computer_gauntlet_btn and flow.computer_gauntlet_btn.valid then
        flow.computer_gauntlet_btn.destroy()

        if global.computerGuis[player.index] then
            global.computerGuis[player.index]:destroy()
            global.computerGuis[player.index] = nil
        end
    end
end
