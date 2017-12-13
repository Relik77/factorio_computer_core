require("logic.computer")

function getUniqueName(table, name, number)
    if not number then
        local index
        local next = name:find("-")
        while next do
            index = next
            next = name:find("-", index + 1)
        end
        if index then
            number = tonumber(name:sub(index + 1))
            if number then
                number = number + 1
                name = name:sub(1, index - 1)
            else
                number = 1
            end
        else
            for index, value in pairs(table) do
                if value == name then
                    return getUniqueName(table, name, 1)
                end
            end
            return name
        end
    end
    for index, value in pairs(table) do
        if value == name .. "-" .. number then
            number = number + 1
            return getUniqueName(table, name, number)
        end
    end
    return name .. "-" .. number
end

computer.guis["waypoint"] = {
    prefix = "computer_computerWaypointGui_",

    new = function(player, os)
        local obj = {
            valid = true,

            player = player,
            file = nil,

            waypoints = {},
            waypointsIndex = {},
            waypoint = {
                force = player.force,
                position = {
                    x = player.position.x,
                    y = player.position.y
                },
                name = nil
            },

            children = {
                parent = player.gui.center
            },

            os = nil
        }

        for index, value in pairs(computer.guis["waypoint"]) do
            obj[index] = value
        end

        obj.os = os

        obj:buildGui()
        obj:refreshWaypoints()

        return obj
    end,

    destroy = function(self)
        self.valid = false

        if self.children.root and self.children.root.valid then
            self.children.root.destroy()
        end
    end,

    refreshWaypoints = function(self)
        if not global.waypoints then
            global.waypoints = {}
        end

        self.waypoints = {}
        self.waypointsIndex = {}
        for index, waypoint in pairs(global.waypoints) do
            if waypoint.force == self.player.force then
                self.waypoints[waypoint.name] = waypoint
                table.insert(self.waypointsIndex, waypoint.name)
            end
        end
        self.children.listWaypoint.items = self.waypointsIndex
    end,

    OnGuiClick = function(self, event)
        local name = event.element.name

        if name == self.prefix .. "rootFrame" and event.button == defines.mouse_button_type.right then
            self.os:closeGui()
        elseif name == self.prefix .. "backbtn" then
            self.os:openGui("console")
        elseif name == self.prefix .. "addWaypointBtn" then
            self.waypoint = {
                force = self.player.force,
                position = {
                    x = self.player.position.x,
                    y = self.player.position.y
                },
                name = nil
            }
            self.children.listWaypoint.selected_index = 0
        elseif name == self.prefix .. "deleteBtn" then
            if self.waypoint.name ~= nil then
                self.waypoints[self.waypoint.name] = nil
                local index = searchIndexInTable(self.waypointsIndex, self.waypoint.name)

                if index then
                    table.remove(self.waypointsIndex, index)
                end

                self.children.listWaypoint.items = self.waypointsIndex
            end
            self.waypoint = {
                force = self.player.force,
                position = {
                    x = self.player.position.x,
                    y = self.player.position.y
                },
                name = nil
            }
            self.children.listWaypoint.selected_index = 0
        elseif name == self.prefix .. "saveBtn" then
            self:refreshWaypoints()

            if self.waypoint.name ~= nil then
                if #self.children.waypointName.text == 0 then
                    self.children.waypointName.text = self.waypoint.name
                end

                local index = 0
                if self.waypoints[self.waypoint.name] == self.waypoint then
                    self.waypoints[self.waypoint.name] = nil
                    index = searchIndexInTable(self.waypointsIndex, self.waypoint.name)

                    if index then
                        table.remove(self.waypointsIndex, index)
                    end
                end

                self.children.waypointName.text = getUniqueName(self.waypointsIndex, self.children.waypointName.text)
                self.waypoint.name = self.children.waypointName.text
                self.waypoints[self.waypoint.name] = self.waypoint
                table.insert(self.waypointsIndex, index or 0, self.waypoint.name)
                self.children.listWaypoint.items = self.waypointsIndex
                self.children.listWaypoint.selected_index = self.children.listWaypoint.selected_index
            else
                if #self.children.waypointName.text == 0 then
                    self.children.waypointName.text = "nameless"
                end
                self.children.waypointName.text = getUniqueName(self.waypointsIndex, self.children.waypointName.text)
                self.waypoint.name = self.children.waypointName.text
                self.waypoints[self.waypoint.name] = self.waypoint
                table.insert(self.waypointsIndex, self.waypoint.name)
                table.insert(global.waypoints, self.waypoint)
                self.children.listWaypoint.items = self.waypointsIndex
                self.children.listWaypoint.selected_index = #self.waypointsIndex
            end
        end
    end,

    OnGuiTextChanged = function(self, event)
        local gui = event.element

        if not self.valid then
            return
        end
        if gui.name == self.prefix .. "output" then
            return self:print(self.os.data.output)
        elseif gui.name == self.prefix .. "waypointName" then
            if gui.text:sub(#gui.text) == " " then
                gui.text = gui.text:sub(1, #gui.text - 1)
            end
        elseif gui.name == self.prefix .. "waypointPositionX" then
            local val = tonumber(gui.text)
            if val then
                self.waypoint.position.x = val
            else
                gui.text = self.waypoint.position.x
            end
        elseif gui.name == self.prefix .. "waypointPositionY" then
            local val = tonumber(gui.text)
            if val then
                self.waypoint.position.y = val
            else
                gui.text = self.waypoint.position.y
            end
        end
    end,

    OnGuiSelectionStateChanged = function(self, event)
        local gui = event.element

        if gui.name == self.prefix .. "waypointList" then
            local wp = self.waypoints[gui.get_item(gui.selected_index)]
            if wp then
                self.waypoint = wp
                self.children.waypointName.text = wp.name
            end
        end
    end,

    OnTick = function(self)
        if self.waypoint.name == nil then
            self.waypoint.position.x = self.player.position.x
            self.waypoint.position.y = self.player.position.y
        end

        self.children.waypointPositionX.text = "" .. self.waypoint.position.x
        self.children.waypointPositionY.text = "" .. self.waypoint.position.y
        self.children.waypointPreview.position = self.waypoint.position
    end,

    buildGui = function(self)
        local elts = self.children

        if elts.parent[self.prefix .. "rootFrame"] and elts.parent[self.prefix .. "rootFrame"].valid then
            elts.parent[self.prefix .. "rootFrame"].destroy()
        end
        elts.root = elts.parent.add({
            type = "frame",
            name = self.prefix .. "rootFrame",
            caption = "Waypoints",
            direction = "vertical",
        })
        elts.root.style.minimal_width = 800
        elts.root.style.maximal_width = 800
        elts.root.style.minimal_height = 400
        elts.root.style.maximal_height = 700

        -- Body
        elts.body = elts.root.add({
            type = "table",
            name = self.prefix .. "body",
            column_count = 2
        })

        -- Form
        elts.waypointForm = elts.body.add({
            type = "table",
            name = self.prefix .. "waypointForm",
            column_count = 1
        })

        -- Form Caption
        elts.waypointFormCaption = elts.waypointForm.add({
            type = "table",
            name = self.prefix .. "waypointForm",
            column_count = 2
        })


        elts.listWaypoint = elts.waypointFormCaption.add({
            type = "drop-down",
            name = self.prefix .. "waypointList",
            items = self.waypointsIndex,
            selected_index = 0
        })
        elts.listWaypoint.style.minimal_width = 300
        elts.listWaypoint.style.maximal_width = 300
        elts.listWaypoint.style.minimal_height = 40
        elts.listWaypoint.style.maximal_height = 40

        elts.addWaypointBtn = elts.waypointFormCaption.add({
            type = "button",
            name = self.prefix .. "addWaypointBtn",
            caption = "New"
        })
        elts.addWaypointBtn.style.minimal_width = 70
        elts.addWaypointBtn.style.maximal_width = 70
        elts.addWaypointBtn.style.minimal_height = 40
        elts.addWaypointBtn.style.maximal_height = 40

        -- Form Content
        elts.waypointFormContent = elts.waypointForm.add({
            type = "table",
            name = self.prefix .. "waypointFormContent",
            column_count = 2
        })
        elts.waypointFormContent.style.top_padding = 60

        -- Waypoint Name
        elts.waypointNameLabel = elts.waypointFormContent.add({
            type = "label",
            name = self.prefix .. "waypointNameLabel",
            caption = "Name"
        })
        elts.waypointNameLabel.style.minimal_width = 70
        elts.waypointNameLabel.style.maximal_width = 70

        elts.waypointName = elts.waypointFormContent.add({
            type = "textfield",
            name = self.prefix .. "waypointName",
            caption = ""
        })
        elts.waypointName.style.minimal_width = 230
        elts.waypointName.style.maximal_width = 230

        -- Waypoint Position Y
        elts.waypointPositionYLabel = elts.waypointFormContent.add({
            type = "label",
            name = self.prefix .. "waypointPositionYLabel",
            caption = "Latitude"
        })
        elts.waypointPositionYLabel.style.minimal_width = 70
        elts.waypointPositionYLabel.style.maximal_width = 70

        elts.waypointPositionY = elts.waypointFormContent.add({
            type = "textfield",
            name = self.prefix .. "waypointPositionY"
        })
        elts.waypointPositionY.style.minimal_width = 100
        elts.waypointPositionY.style.maximal_width = 100
        elts.waypointPositionY.text = self.waypoint.position.y

        -- Waypoint Position X
        elts.waypointPositionXLabel = elts.waypointFormContent.add({
            type = "label",
            name = self.prefix .. "waypointPositionXLabel",
            caption = "Longitude"
        })
        elts.waypointPositionXLabel.style.minimal_width = 70
        elts.waypointPositionXLabel.style.maximal_width = 70

        elts.waypointPositionX = elts.waypointFormContent.add({
            type = "textfield",
            name = self.prefix .. "waypointPositionX"
        })
        elts.waypointPositionX.style.minimal_width = 100
        elts.waypointPositionX.style.maximal_width = 100
        elts.waypointPositionX.text = self.waypoint.position.y

        -- Save
        elts.waypointFormFooter = elts.waypointForm.add({
            type = "table",
            name = self.prefix .. "waypointFormFooter",
            column_count = 2
        })
        elts.waypointFormFooter.style.left_padding = 230
        elts.waypointFormFooter.style.top_padding = 160

        elts.deleteBtn = elts.waypointFormFooter.add({
            type = "button",
            name = self.prefix .. "deleteBtn",
            caption = "Delete"
        })
        elts.deleteBtn.style.minimal_width = 70
        elts.deleteBtn.style.maximal_width = 70
        elts.deleteBtn.style.minimal_height = 40
        elts.deleteBtn.style.maximal_height = 40

        elts.saveBtn = elts.waypointFormFooter.add({
            type = "button",
            name = self.prefix .. "saveBtn",
            caption = "Save"
        })
        elts.saveBtn.style.minimal_width = 70
        elts.saveBtn.style.maximal_width = 70
        elts.saveBtn.style.minimal_height = 40
        elts.saveBtn.style.maximal_height = 40

        -- Camera
        elts.waypointPreview = elts.body.add({
            type = "camera",
            name = self.prefix .. "waypointPreview",
            position = self.waypoint.position,
            zoom = 0.75
        })
        elts.waypointPreview.style.minimal_width = 400
        elts.waypointPreview.style.maximal_width = 400
        elts.waypointPreview.style.minimal_height = 400
        elts.waypointPreview.style.maximal_height = 400

        -- Footer
        elts.footer = elts.root.add({
            type = "table",
            name = self.prefix .. "footer",
            column_count = 1
        })
        elts.footer.style.left_padding = 690

        --elts.backbtn = elts.footer.add({
        --    type = "flow",
        --    name = self.prefix .. "space"
        --})
        --elts.backbtn.style.minimal_width = 690
        --elts.backbtn.style.maximal_width = 690

        elts.backbtn = elts.footer.add({
            type = "button",
            name = self.prefix .. "backbtn",
            caption = "Back"
        })
        elts.backbtn.style.minimal_width = 85
        elts.backbtn.style.maximal_width = 85
    end
}
