require("logic.computer")

computer.guis["output"] = {
    prefix = "computer_computerOutputGui_",

    new = function (player, os)
        local obj = {
            valid = true,

            player = player,
            file = nil,

            children = {
                parent = player.gui.center
            },

            os = nil
        }

        for index, value in pairs(computer.guis["output"]) do
            obj[index] = value
        end

        obj.os = os

        obj:buildGui()
        obj:print(obj.os.data.output)

        return obj
    end,

    destroy = function(self)
        self.valid = false

        if self.children.root and self.children.root.valid then
            self.children.root.destroy()
        end
    end,

    OnGuiClick = function(self, event)
        local name = event.element.name

        if name == self.prefix .. "rootFrame" and event.button == defines.mouse_button_type.right then
            self.os:closeGui()
        elseif name == self.prefix .. "stopbtn" then
            self.os.data.file = nil
            self.os:exec("stop", false)
            self.os:openGui("console")
        elseif name == self.prefix .. "editbtn" then
            self.os:exec("stop", false)
            self.os:exec("edit", self.file)
        end
    end,

    OnGuiTextChanged = function(self, event)
        local gui = event.element

        if not self.valid then return end
        if gui.name == self.prefix .. "output" then
            return self:print(self.os.data.output)
        end
    end,

    print = function(self, text)
        if self.valid then
            self.children.output.text = text
        end
    end,

    buildGui = function(self)
        local elts = self.children

        if elts.parent[self.prefix .. "rootFrame"] and elts.parent[self.prefix .. "rootFrame"].valid then
            elts.parent[self.prefix .. "rootFrame"].destroy()
        end
        elts.root = elts.parent.add({
            type = "frame",
            name = self.prefix .. "rootFrame",
            caption = "Output",
            direction = "vertical",
        })
        elts.root.style.minimal_width = 800
        elts.root.style.maximal_width = 800
        elts.root.style.minimal_height = 400
        elts.root.style.maximal_height = 700

        elts.buttonFlow = elts.root.add({
            type = "flow",
            name = self.prefix .. "btnFlow",
        })

        elts.output = elts.buttonFlow.add({
            type = "text-box",
            name = self.prefix .. "output"
        })
        elts.output.style.minimal_width = 800
        elts.output.style.maximal_width = 800
        elts.output.style.minimal_height = 400
        elts.output.style.maximal_height = 400

        elts.footer = elts.root.add({
            type = "table",
            name = self.prefix .. "footer",
            column_count = 3
        })

        elts.input = elts.footer.add({
            type = "label",
            name = self.prefix .. "input"
        })
        elts.input.style.minimal_width = 600
        elts.input.style.maximal_width = 600
        elts.input.style.minimal_height = 40
        elts.input.style.maximal_height = 40

        elts.editbtn = elts.footer.add({
            type = "button",
            name = self.prefix .. "editbtn",
            caption="Edit"
        })
        elts.editbtn.style.minimal_width = 85
        elts.editbtn.style.maximal_width = 85

        elts.stopbtn = elts.footer.add({
            type = "button",
            name = self.prefix .. "stopbtn",
            caption="Stop"
        })
        elts.stopbtn.style.minimal_width = 85
        elts.stopbtn.style.maximal_width = 85
    end
}
